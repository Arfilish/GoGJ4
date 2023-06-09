extends RigidBody2D
class_name PlayerOrb

const BOUNCE_STREAM: AudioStream = preload("res://Assets/Sounds/Gameplay/OrbBounce.tres");

@export var start_holder: OrbHolder;

@onready var collision: CollisionShape2D = $CollisionShape2D;
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer;

var holder: OrbHolder = null;
var _tp: bool = false;
var _tp_pos: Vector2 = Vector2.ZERO;


func _ready() -> void:
    if (is_instance_valid(start_holder)):
        start_holder.hold.call_deferred(self);


func teleport(p_pos: Vector2) -> void:
    _tp_pos = p_pos;
    _tp = true;


func disable() -> void:
    set_physics_process(false);
    set_deferred(&"freeze", true);
    collision.set_deferred(&"disabled", true);


func enable() -> void:
    set_physics_process(true);
    set_deferred(&"freeze", false);
    collision.set_deferred(&"disabled", false);


func _integrate_forces(p_state: PhysicsDirectBodyState2D) -> void:
    if (_tp):
        p_state.transform = Transform2D(0.0, _tp_pos);
        _tp = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_d: float) -> void:
    position = position.clamp(Vector2(16.0, 16.0), Vector2(464.0, 344.0));
    if (position.y <= 16.0 or position.y >= 344.0):
        linear_velocity = linear_velocity.bounce(Vector2.UP);
    if (position.x <= 16.0 or position.x >= 464.0):
        linear_velocity = linear_velocity.bounce(Vector2.RIGHT);


func push(p_n: Vector2, p_power: float = 1.0) -> void:
    linear_velocity = (p_n * p_power - Vector2(0.0, p_power / 2.0)).rotated(randf_range(PI / -8, PI / 8));


func _on_body_entered(p_body: Node) -> void:
    sound_player.stream = BOUNCE_STREAM;
    sound_player.play();
    if (p_body.has_method(&"take_damage")):
        var result: DamageResult = DamageResult.new(25.0, self, self, linear_velocity);
        p_body.take_damage(result);
