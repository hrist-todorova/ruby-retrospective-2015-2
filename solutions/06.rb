require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class TurtleGraphics

  class Turtle
    def initialize(rows, columns)
      @rows = rows
      @columns = columns
      @matrix = Matrix.build(@rows, @columns){ 0 }
      @orientation = :right
      @changed_orientation = :right

      @moves = 0
      @xcoordinate = 0
      @ycoordinate = 0
      @spin = 0
    end

      def draw(ascii = nil)
        if ascii == nil
          self.instance_eval(&Proc.new) if block_given?
          @matrix.to_a
        else
          #ForASCII.new(@matrix.to_a)
        end
      end

      def check_position
        @xcoordinate = 0 if @xcoordinate >= @columns
        @xcoordinate = @columns - 1 if @xcoordinate <= - 1
        @ycoordinate = 0 if @ycoordinate >= @rows
        @ycoordinate = @rows - 1 if @ycoordinate <= - 1
      end

      def move
        @matrix[@ycoordinate,@xcoordinate] += 1 if @moves == 0
        look(@changed_orientation)

        @xcoordinate += 1 if @orientation == :right
        @xcoordinate -= 1 if @orientation == :left
        @ycoordinate -= 1 if @orientation == :up
        @ycoordinate += 1 if @orientation == :down

        @moves += 1
        check_position
        @matrix[@ycoordinate,@xcoordinate] += 1
      end

      def turn_left
        @spin -= 1
        if @spin == -4
          @spin = 0
        end
      end

      def turn_right
        @spin += 1
        if @spin == 4
          @spin = 0
        end
      end

      def spawn_at(row, column)
        @ycoordinate = row
        @xcoordinate = column
      end

      def look(orientation = :right)
        @changed_orientation = orientation

        right_side(orientation)
        left_side(orientation)
      end

      def right_side(orientation)
        if @spin == 0
          @orientation = :down if orientation == :down
          @orientation = :up if orientation == :up
          @orientation = :right if orientation == :right
          @orientation = :left if orientation == :left
        elsif (@spin == 1 or @spin == -3)
          @orientation = :down if orientation == :right
          @orientation = :up if orientation == :left
          @orientation = :right if orientation == :up
          @orientation = :left if orientation == :down
           end
      end


      def left_side(orientation)
        if (@spin == 2 or @spin == -2)
          @orientation = :up if orientation == :down
          @orientation = :down if orientation == :up
          @orientation = :left if orientation == :right
          @orientation = :right if orientation == :left
        elsif (@spin == 3 or @spin == -1)
          @orientation = :right if orientation == :down
          @orientation = :left if orientation == :up
          @orientation = :up if orientation == :right
          @orientation = :down if orientation == :left
        end
      end

      class ForASCII

        def initialize(array_of_arrays)
          @matrix = array_of_arrays
        end

        def matrix
          @matrix
        end

      end

      class Canvas

        class ASCII
          def initialize(array_of_symbols_to_draw)
            @patterns = array_of_symbols_to_draw
          end

          def size
            @patterns.length
          end

             def next_pattern
            if size != 0
              @patterns.shift
            elsif
              @patterns.first
            end
          end
        end

        class HTML

          def initialize(pixel_size)
            @size = pixel_size
          end
        end
      end

  end

end
