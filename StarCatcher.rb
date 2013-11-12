require 'rubygems'
require 'gosu'
require '.\\Player'
require '.\\Star'
require '.\\Shot'
require '.\\Bubble'

class GameWindow < Gosu::Window

  attr_accessor :shots
  def initialize
    @sneak_mode = true
    if @sneak_mode then 
      super 320, 240, false
    else
      super 2048, 1024, false
    end
    self.caption = 'Stars!'


    @background_image = Gosu::Image.new(self, "media/Space.png", true)

    @player = Player.new(self)
    @player.warp(self.width / 2, self.height / 2)

    @star_anim = Gosu::Image::load_tiles(self, "media/Star.png", 25, 25, false)
    @stars = Array.new

    @bubble_image = Gosu::Image.new(self, 'media/ForceField.png', true)
    @bubbles = Array.new

    @shot_image = Gosu::Image.new(self, 'media/rocket_flame.png', true)
    @shots = Array.new

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    if @player.health > 0
      if button_down? Gosu::KbLeft then
        @player.turn_left
      end

      if button_down? Gosu::KbRight then
        @player.turn_right
      end

      if button_down? Gosu::KbUp then
        @player.accelerate
      else
        @player.burn = false
      end

      if button_down? Gosu::KbDown then
        @player.warp(rand * self.width, rand * self.height)
      end

      if button_down? Gosu::KbSpace then
        @player.shake
        @player.shot_power += 1 unless @player.shot_power == 500
      else
        @player.shot_power -= 1 unless @player.shot_power.zero?
      end

      if button_down? Gosu::KbZ and @shots.length < 1 then
        @shots.push(Shot.new(self, @shot_image, @player))
      end

      if button_down? Gosu::KbQ then
        @player.health = 0
      end

      if button_up(Gosu::KbSpace) then
        @shots.push(Shot.new(self, @shot_image, @player))
      end
    end

    @player.move
    if !@sneak_mode then
      @player.collect_stars(@stars) if @player.health > 0
      @bubbles.each {|bubble| bubble.move; bubble.collect_stars(@stars); bubble.attack(@player)}
    end
      @shots.each {|shot| shot.move; shot.cause_damage(@bubbles)}

    if rand(100) < 4 and @stars.size < 25 then
      @stars.push(Star.new(@star_anim, self))
    end

    if rand(100) < 4 and @bubbles.size < 3 then
      @bubbles.push(Bubble.new(@bubble_image, self))
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background, (self.width.to_f/@background_image.width.to_f), (self.height.to_f/@background_image.height.to_f)) unless @sneak_mode
    @player.draw
    @stars.each {|star| star.draw} unless @sneak_mode
    @bubbles.each {|bubble| bubble.draw} unless @sneak_mode
    @shots.each {|shot| shot.draw}
    
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
    @font.draw("Life: #{@player.health}", 10, 25, ZOrder::UI, 1.0, 1.0, @player.health > 0 ? 0xff00ff00 : 0xffff0000)
    @font.draw("Shot power: #{@player.shot_power}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    # @font.draw("Shots: #{@shots.length}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    # if @shots.length > 0 then
    #   @font.draw("Shot: #{@shots[0].x.to_i.abs}, #{@shots[0].y.to_i.abs}", 10, 55, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    # end
    # @font.draw("Window: #{self.width}, #{self.height}", 10, 70, ZOrder::UI, 1.0, 1.0, 0xffff0000)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

module ZOrder
  Background, Stars, Player, Shield, UI = *0..4
end

window = GameWindow.new
window.show