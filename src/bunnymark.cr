require "raylib-cr"

MAX_BUNNIES        = 1000000
MAX_BATCH_ELEMENTS =   8192

struct Bunny
  property x : Int32
  property y : Int32
  property vx : Int32
  property vy : Int32
  property color : Raylib::Color

  def initialize(@x : Int32, @y : Int32, @vx : Int32, @vy : Int32, @color : Raylib::Color)
  end
end

def main
  screen_width = 800
  screen_height = 450

  Raylib.init_window(screen_width, screen_height, "raylib [textures] example - bunnymark")

  tex_bunny = Raylib.load_texture("resources/raybunny.png")

  bunny_half_width = tex_bunny.width / 2.0
  bunny_half_height = tex_bunny.height / 2.0

  bunnies = [] of Bunny
  bunnies_count = 0
  paused = false

  Raylib.set_target_fps(60)

  until Raylib.close_window?
    # Update
    if Raylib.mouse_button_down?(Raylib::MouseButton::Left)
      mouse_x = Raylib.get_mouse_position.x.to_i
      mouse_y = Raylib.get_mouse_position.y.to_i
      # Create more bunnies
      100.times do
        if bunnies_count < MAX_BUNNIES
          color = Raylib::Color.new
          color.r = Raylib.get_random_value(50, 240).to_u8
          color.g = Raylib.get_random_value(80, 240).to_u8
          color.b = Raylib.get_random_value(100, 240).to_u8
          color.a = 255
          vx = (Random.rand(-250..250) / 60).to_i
          vy = (Random.rand(-250..250) / 60).to_i
          bunnies << Bunny.new(mouse_x, mouse_y, vx, vy, color)
          bunnies_count += 1
        end
      end
    end

    if Raylib.key_pressed?(Raylib::KeyboardKey::P)
      paused = !paused
    end

    unless paused
      # Update bunnies
      bunnies.each_index do |i|
        bunny = bunnies[i]
        bunny.x += bunny.vx
        bunny.y += bunny.vy

        if (bunny.x + bunny_half_width) > screen_width ||
           (bunny.x + bunny_half_width) < 0
          bunny.vx *= -1
        end
        if (bunny.y + bunny_half_height) > screen_height ||
           (bunny.y + bunny_half_height - 40) < 0
          bunny.vy *= -1
        end

        bunnies[i] = bunny
      end
    end

    # Draw
    Raylib.begin_drawing
    Raylib.clear_background(Raylib::RAYWHITE)

    bunnies.each do |bunny|
      Raylib.draw_texture(tex_bunny, bunny.x, bunny.y, bunny.color)
    end

    Raylib.draw_rectangle(0, 0, screen_width, 40, Raylib::BLACK)
    Raylib.draw_text("bunnies: #{bunnies_count}", 120, 10, 20, Raylib::GREEN)
    Raylib.draw_text("batched draw calls: #{1 + (bunnies_count / MAX_BATCH_ELEMENTS).to_i}", 320, 10, 20, Raylib::MAROON)

    Raylib.draw_fps(10, 10)
    Raylib.end_drawing
  end

  Raylib.unload_texture(tex_bunny)
  Raylib.close_window
end

main
