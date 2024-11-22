extends RigidBody3D

@export var image_texture: Texture2D = preload("res://image.png")  # Preload the image

# Function to add the image as a Sprite3D on the MeshInstance3D
func add_image_to_mesh() -> void:
    var mesh_instance = get_node("MeshInstance3D") as MeshInstance3D  # Get the child MeshInstance3D (cube)

    if mesh_instance:
        # Create a new Sprite3D node
        var sprite = Sprite3D.new()
        sprite.texture = image_texture  # Assign the texture (image)
        
        # Add the Sprite3D as a child of the mesh
        mesh_instance.add_child(sprite)

        # Get the size of the texture
        var texture_size = image_texture.get_size()  # This returns a Vector2 (width, height)
        #print("texture_size", texture_size)
        
        # Get the size of the cube (assuming it's 1 unit)
        var cube_size = mesh_instance.get_aabb().size  # Replace this with your cube's actual size if it's different
        #print("cube_size: ", cube_size)

        # Calculate the scale factors based on the texture size
        # We assume that the Z dimension is the thickness of the cube
        var scale_x = cube_size.x / texture_size.x
        #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)
        var scale_y = cube_size.y / texture_size.y
        #print("cube_size.x / texture_size.x = ", cube_size.x / texture_size.x)

        
        # Choose the smaller scale factor to maintain aspect ratio
        var scale_factor = min(scale_x, scale_y)
        #print("scale_factor: ", scale_factor)

        # Scale the sprite to fit within the cube
        sprite.scale = Vector3(0.1, 0.1, 1)  # Keep Z scale to 1 for flat texture
        
        # Position the sprite on the front face of the cube (adjust position if necessary)
        sprite.transform.origin = Vector3(0, 0, -0.51)  # Position slightly in front of the cube face

        #print("Image applied to the mesh's face.")
    else:
        print("MeshInstance3D not found!")
