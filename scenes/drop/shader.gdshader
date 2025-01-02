shader_type spatial;

uniform float emission_intensity : hint_range(0.0, 100.0) = 10.0; // Intensidade de emissão
uniform float speed : hint_range(10.0, 60.0) = 10.0; // Intensidade de emissão
uniform float min_speed : hint_range(5.0, 550.0) = 5;  // Velocidade mínima
uniform float max_speed : hint_range(5.0, 550.0) = 150.0;  // Velocidade máxima
uniform vec3 max_color = vec3(0.0, 0.0, 1.0); // Cor azul para velocidades máximas
uniform vec3 min_color = vec3(1.0, 1.0, 1.0); // Cor branca para velocidades mínimas

void fragment() {
    vec3 emission_color = mix(min_color, max_color, (emission_intensity - min_speed) / (max_speed - min_speed));
    EMISSION = emission_color * emission_intensity;
}