import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';

class AsteroidComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  AsteroidComponent({super.priority, this.isOrbiting}) {
    isOrbiting = false;
  }

  late bool? isOrbiting;
  @override
  Body createBody() {
    final def = BodyDef(
      userData: this,
      isAwake: true,
      type: BodyType.dynamic,
      position: game.asteroidPosition,
    );

    final body = world.createBody(def)..userData = this;
    final circle = CircleShape(radius: .5, position: Vector2.zero());
    body.createFixtureFromShape(
      PolygonShape()
        ..set([Vector2(0, 0), Vector2(.5, 0), Vector2(.5, .7), Vector2(0, .7)]),
    );
    body.createFixtureFromShape(circle);
    body.synchronizeFixtures();
    body.applyLinearImpulse(Vector2(11, -17));
    body.setMassData(MassData()..mass = 1.2);
    return body;
  }

  // @override
  // void update(double dt) {
  //   updateMovement();
  //   super.update(dt);
  // }

  // void updateMovement() {
  //   final desiredSpeed = 50;
  //   final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
  //   final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
  //   var force = 0.0;
  //   if (desiredSpeed < currentSpeed) {
  //     force = -_maxDriveForce;
  //   } else if (desiredSpeed > currentSpeed) {
  //     force = _maxDriveForce;
  //   }
  //   print(currentSpeed);

  //   body.applyForce(currentForwardNormal..scale(30));
  // }

  final Vector2 _worldRight = Vector2(-1, 0.0);

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldRight);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
