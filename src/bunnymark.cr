require "raylib-cr"

MAX_BUNNIES        = 1000000
MAX_BATCH_ELEMENTS =   8192

struct Bunny
  property position : Array(Int32)
  property speed : Array(Int32)
  property color : Raylib::Color

  def initialize(@position : Array(Int32), @speed : Array(Int32), @color : Raylib::Color)
  end
end

def main
  screen_width = 800
  screen_height = 450

  Raylib.init_window(screen_width, screen_height, "raylib [textures] example - bunnymark")

  tex_bunny = Raylib.load_texture("resources/raybunny.png")

  bunnies = [] of Bunny
  bunnies_count = 0
  paused = false

  Raylib.set_target_fps(60)

  until Raylib.close_window?
    # Update
    if Raylib.mouse_button_down?(Raylib::MouseButton::Left)
      # Create more bunnies
      100.times do |i|
        if bunnies_count < MAX_BUNNIES
          position = [Raylib.get_mouse_position.x.to_i, Raylib.get_mouse_position.y.to_i]
          speed = [0, 0]
          speed[0] = (Random.rand(-250..250) / 60).to_i
          speed[1] = (Random.rand(-250..250) / 60).to_i
          color = Raylib::Color.new
          color.r = Raylib.get_random_value(50, 240).to_u8
          color.g = Raylib.get_random_value(80, 240).to_u8
          color.b = Raylib.get_random_value(100, 240).to_u8
          color.a = 255
          bunnies << Bunny.new(position, speed, color)
          bunnies_count += 1
        end
      end
    end

    if Raylib.key_pressed?(Raylib::KeyboardKey::P)
      paused = !paused
    end

    unless paused
      # Update bunnies
      bunnies.each do |bunny|
        # Update position
        pos = bunny.position
        pos[0] += bunny.speed[0]
        pos[1] += bunny.speed[1]
        bunny.position = pos

        # Check boundaries and reverse direction if needed
        if ((pos[0] + tex_bunny.width / 2.0) > Raylib.get_screen_width()) ||
           ((pos[0] + tex_bunny.width / 2.0) < 0)
          bunny.speed[0] *= -1
        end
        if ((pos[1] + tex_bunny.height / 2.0) > Raylib.get_screen_height()) ||
           ((pos[1] + tex_bunny.height / 2.0 - 40) < 0)
          bunny.speed[1] *= -1
        end
      end
    end

    # Draw
    Raylib.begin_drawing
    Raylib.clear_background(Raylib::RAYWHITE)

    bunnies.each do |bunny|
      Raylib.draw_texture(tex_bunny, bunny.position[0], bunny.position[1], bunny.color)
    end

    Raylib.draw_rectangle(0, 0, screen_width, 40, Raylib::BLACK)
    Raylib.draw_text("bunnies: #{bunnies_count}", 120, 10, 20, Raylib::GREEN)
    Raylib.draw_text("batched draw calls: #{1 + bunnies_count / MAX_BATCH_ELEMENTS}", 320, 10, 20, Raylib::MAROON)

    Raylib.draw_fps(10, 10)
    Raylib.end_drawing
  end

  Raylib.unload_texture(tex_bunny)
  Raylib.close_window
end

main
