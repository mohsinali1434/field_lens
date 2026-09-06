import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:field_lens/core/services/location_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Map view for inspection location capture.
class LocationMapPage extends StatefulWidget {
  const LocationMapPage({required this.inspectionId, super.key});

  final String inspectionId;

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  final _mapController = MapController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isSaving = ValueNotifier<bool>(false);
  final ValueNotifier<LatLng?> _position = ValueNotifier<LatLng?>(null);
  InspectionEntity? _inspection;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _isSaving.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await sl<InspectionRepository>().getInspectionById(
      widget.inspectionId,
    );
    if (!mounted) return;

    await result.fold(
      onSuccess: (inspection) async {
        LatLng? position;
        if (inspection.latitude != null && inspection.longitude != null) {
          position = LatLng(inspection.latitude!, inspection.longitude!);
        } else {
          final location = await sl<LocationService>().getCurrentLocation();
          if (location.isSuccess) {
            position = LatLng(
              location.valueOrNull!.latitude,
              location.valueOrNull!.longitude,
            );
          }
        }

        _inspection = inspection;
        _position.value = position;
        _isLoading.value = false;
      },
      onFailure: (failure) {
        _isLoading.value = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<void> _useCurrentLocation() async {
    _isSaving.value = true;
    final location = await sl<LocationService>().getCurrentLocation();
    if (!mounted) return;

    location.fold(
      onSuccess: (coords) {
        final point = LatLng(coords.latitude, coords.longitude);
        _position.value = point;
        _isSaving.value = false;
        _mapController.move(point, 15);
      },
      onFailure: (failure) {
        _isSaving.value = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<void> _save() async {
    final inspection = _inspection;
    final position = _position.value;
    if (inspection == null || position == null) return;

    _isSaving.value = true;
    final result = await sl<InspectionActivityService>().updateLocation(
      inspection: inspection,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(true),
      onFailure: (failure) {
        _isSaving.value = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Location',
      showBackButton: true,
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (BuildContext context, bool isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<LatLng?>(
            valueListenable: _position,
            builder: (BuildContext context, LatLng? position, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isSaving,
                builder: (BuildContext context, bool isSaving, _) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: position == null
                            ? Center(
                                child: Text(
                                  'Location unavailable',
                                  style: context.textTheme.bodyLarge,
                                ),
                              )
                            : FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: position,
                                  initialZoom: 15,
                                  onTap: (_, LatLng point) {
                                    _position.value = point;
                                  },
                                ),
                                children: <Widget>[
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.fieldlens.app',
                                  ),
                                  MarkerLayer(
                                    markers: <Marker>[
                                      Marker(
                                        point: position,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: <Widget>[
                            AppButton(
                              label: 'Use Current Location',
                              icon: Icons.my_location_rounded,
                              variant: AppButtonVariant.secondary,
                              expand: true,
                              isLoading: isSaving,
                              onPressed: isSaving ? null : _useCurrentLocation,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Save Location',
                              expand: true,
                              isLoading: isSaving,
                              onPressed: isSaving || position == null
                                  ? null
                                  : _save,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
