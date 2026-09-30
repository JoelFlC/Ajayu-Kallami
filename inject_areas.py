import os

def inject_trigger(file_path):
    with open(file_path, "r") as f:
        content = f.read()
    
    # We'll just append it to the end of the file. Godot is fine with it.
    new_nodes = """
[node name="ZonaTrigger" type="Area2D" parent="."]
position = Vector2(504, -1350)
collision_layer = 0
collision_mask = 2

[node name="Color" type="ColorRect" parent="ZonaTrigger"]
offset_left = -30.0
offset_top = -30.0
offset_right = 30.0
offset_bottom = 30.0
color = Color(1, 0, 0, 0.4)

[node name="Forma" type="CollisionShape2D" parent="ZonaTrigger"]
shape = SubResource("RectangleShape2D_trigger")
"""
    # Wait, we need to declare the SubResource for the RectangleShape2D at the top!
    # Let's find the end of the ExtResources/SubResources section
    lines = content.split('\n')
    last_res = 0
    for i, l in enumerate(lines):
        if l.startswith("[ext_resource") or l.startswith("[sub_resource"):
            last_res = i
            
    subresource = '[sub_resource type="RectangleShape2D" id="RectangleShape2D_trigger"]\nsize = Vector2(60, 60)\n'
    
    lines.insert(last_res + 1, subresource)
    
    content = "\n".join(lines) + new_nodes
    
    with open(file_path, "w") as f:
        f.write(content)

inject_trigger("cliente/niveles/pruebas/set_ofrenda.tscn")
inject_trigger("cliente/niveles/pruebas/set_mesa_ritual.tscn")
print("Areas injected.")
