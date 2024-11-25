extends RigidBody3D

@export var image_texture: Texture2D = preload("res://image.png")  # Preload the image



func add_image_to_present(image: Image):
    print("[DEBUG] Adding new image to present")

    var mesh : MeshInstance3D = get_node("MeshInstance3D")
    if not mesh:
        return
    
    var material = mesh.get_active_material(0)
    print("Material", material)
    material.albedo_texture = ImageTexture.create_from_image(image)






# Function to add the image as a Sprite3D on theq MeshInstance3D
# func add_image_to_mesh(image) -> void:

#     print("[DEBUG] Adding image to mesh ", image)
#     var mesh_instance = get_node("MeshInstance3D") as MeshInstance3D  # Get the child MeshInstance3D (cube)

#     if mesh_instance:
#         # Create a new Sprite3D node
#         var sprite = Sprite3D.new()
#         var texture = ImageTexture.create_from_image(image)
        
#         sprite.texture = texture
#         mesh_instance.add_child(sprite)

#         # Get the size of the texture
#         var texture_size = texture.get_size()  # This returns a Vector2 (width, height)
#         print("[DEBUG] Texture size: ", texture_size)
        
#         # Get the size of the cube (assuming it's 1 unit)
#         var cube_size = mesh_instance.get_aabb().size
#         print("[DEBUG] Cube size: ", cube_size)

#         # Calculate the scale factors based on the texture size
#         # We assume that the Z dimension is the thickness of the cube
#         var scale_x = cube_size.x / texture_size.x
#         #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)
#         var scale_y = cube_size.y / texture_size.y
#         #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)

        
#         # Choose the smaller scale factor to maintain aspect ratio
#         var scale_factor = min(scale_x, scale_y)
#         #print("scale_factor: ", scale_factor)

#         # Scale the sprite to fit within the cube
#         sprite.scale = Vector3(0.1, 0.1, 1)  # Keep Z scale to 1 for flat texture
        
#         # Position the sprite on the front face of the cube (adjust position if necessary)
#         sprite.transform.origin = Vector3(0, 0, -0.51)  # Position slightly in front of the cube face

#         #print("Image applied to the mesh's face.")
#     else:
#         print("MeshInstance3D not found!")


# func add_image_to_mesh(image) -> void:

#     print("[DEBUG] Adding image to mesh ", image)
#     var mesh_instance = get_node("MeshInstance3D") as MeshInstance3D  # Get the child MeshInstance3D (cube)

#     if mesh_instance:
#         # Create a new Sprite3D node
#         var sprite = Sprite3D.new()
#         var texture = ImageTexture.create_from_image(image)
        
#         sprite.texture = texture
#         mesh_instance.add_child(sprite)

#         # Get the size of the texture
#         var texture_size = texture.get_size()  # This returns a Vector2 (width, height)
#         print("[DEBUG] Texture size: ", texture_size)
        
#         # Get the size of the cube (assuming it's 1 unit)
#         var cube_size = mesh_instance.get_aabb().size
#         print("[DEBUG] Cube size: ", cube_size)

#         # Calculate the scale factors based on the texture size
#         # We assume that the Z dimension is the thickness of the cube
#         var scale_x = cube_size.x / texture_size.x
#         #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)
#         var scale_y = cube_size.y / texture_size.y
#         #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)

        
#         # Choose the smaller scale factor to maintain aspect ratio
#         var scale_factor = min(scale_x, scale_y)
#         #print("scale_factor: ", scale_factor)

#         # Scale the sprite to fit within the cube
#         sprite.scale = Vector3(0.1, 0.1, 1)  # Keep Z scale to 1 for flat texture
        
#         # Position the sprite on the front face of the cube (adjust position if necessary)
#         sprite.transform.origin = Vector3(0, 0, -0.51)  # Position slightly in front of the cube face

#         #print("Image applied to the mesh's face.")
#     else:
#         print("MeshInstance3D not found!")
