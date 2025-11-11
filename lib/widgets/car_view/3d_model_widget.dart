import 'package:car_dashboard/controllers/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:provider/provider.dart';

class ModelWidget extends StatefulWidget {
  const ModelWidget({super.key});

  @override
  State<ModelWidget> createState() => _ModelWidgetState();
}

class _ModelWidgetState extends State<ModelWidget> {
  late three.ThreeJS threeJs;
  three.AnimationMixer? mixer;
  List<three.AnimationAction> actions = [];
  List<String> animationNames = [];
  three.Object3D? modelRoot;
  List<three.Mesh> headlightMeshes = [];
  bool headlightsOn = false;

  final Map<three.Mesh, three.Material> originalMaterials = {};

  double cameraX = 2.8;
  double cameraY = 2.2;
  double cameraZ = 8.5;

  @override
  void initState() {
    super.initState();
    threeJs = three.ThreeJS(
      onSetupComplete: () => setState(() {}),
      setup: setup,
    );
  }

  Future<void> setup() async {
    final size = MediaQuery.of(context).size;
    final modelWidth = size.width / 3;
    final modelHeight = size.height;
    final cameraController = context.read<CameraController>();


    threeJs.camera = three.PerspectiveCamera(
      35,
      modelWidth / modelHeight,
      0.1,
      2000,
    );

    threeJs.camera.position.setValues(cameraX, cameraY, cameraZ);
    threeJs.camera.lookAt(three.Vector3(0, 0.7, 0.56));
    cameraController.setCamera(threeJs.camera);

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color(0.09, 0.09, 0.086);

    threeJs.scene.add(three.AmbientLight(0xffffff, 0.5));
    final directional = three.DirectionalLight(0xffffff, 3);
    directional.position.setValues(5, 10, 7);
    threeJs.scene.add(directional);

    final loader = three.GLTFLoader(flipY: true).setPath('assets/models/');
    final gltfData = await loader.fromAsset('Seperatedescort.glb');
    if (gltfData == null) return;

    modelRoot = gltfData.scene;
    threeJs.scene.add(modelRoot!);

    setupHeadlights();

    if (gltfData.animations!.isNotEmpty) {
      mixer = three.AnimationMixer(modelRoot!);
      for (var clip in gltfData.animations!) {
        final action = mixer!.clipAction(clip)!;
        action.loop = three.LoopRepeat;
        actions.add(action);
        animationNames.add(
          clip.name.isNotEmpty
              ? clip.name
              : 'anim #${animationNames.length + 1}',
        );
      }
    }

    threeJs.addAnimationEvent((dt) {
      if (mixer != null) mixer!.update(dt);
    });
  }

  void setupHeadlights() {
    if (modelRoot == null) return;
    headlightMeshes.clear();
    modelRoot!.traverse((obj) {
      if (obj is three.Mesh &&
          (obj.name.toLowerCase() == 'left_headlight' ||
              obj.name.toLowerCase() == 'right_headlight')) {
        headlightMeshes.add(obj);
        originalMaterials[obj] = obj.material!;
        final light = three.PointLight(0xffffff, 0.0, 10.0);
        obj.add(light);
        obj.userData['light'] = light;
      }
    });
  }

  Future<void> toggleHeadlights() async {
    if (headlightMeshes.isEmpty) return;
    headlightsOn = !headlightsOn;
    const maxLightIntensity = 0.5;
    for (final mesh in headlightMeshes) {
      if (headlightsOn) {
        mesh.material = three.MeshStandardMaterial.fromMap({
          'color': 0xffffff,
          'metalness': 0.0,
          'roughness': 0.1,
        });
      } else {
        mesh.material = originalMaterials[mesh]!;
        mesh.material!.needsUpdate = true;
      }
    }

    for (double i = 0; i <= 1.0; i += 0.1) {
      final factor = headlightsOn ? i : 1 - i;

      for (final mesh in headlightMeshes) {
        final light = mesh.userData['light'] as three.PointLight?;
        if (light != null) light.intensity = factor * maxLightIntensity;
      }
      await Future.delayed(const Duration(milliseconds: 30));
    }

    setState(() {});
  }

  @override
  void dispose() {
    for (final a in actions) {
      try {
        a.stop();
      } catch (_) {}
    }
    mixer?.dispose();
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return threeJs.build();
  }
}
