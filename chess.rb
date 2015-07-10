class Board #should read each piece every turn and display thier icon
  attr_reader :grid
  def initialize(game = "") #start a new game
    if game != ""
      grid = YAML::load_file('save')
    else
      grid = Array.new(8){Array.new (8) {Cell.new}}
    end
    @grid = grid
  end
  
  def load()  #load the saved game
      puts "loading file"
      @grid = YAML::load_file('save')
      puts @grid
      puts "file loaded"
      @grid
  end 
  
  def save()
    puts "Welcome to Board#save"
    game = @grid.to_yaml
    print game
    File.open('save', 'w') { |f| f.write @grid.to_yaml}
    throw :gameover
  end
    
 
  
  def display #writes from top to bottom
    count = 0
    count1=0
    @grid.each do |row|
      print count, "     ","|"
      row.each do |cell|
       
        print cell.value
        print "|"
        end 
      count +=1
      print "\n      ________________\n" #new row
    end
    print "\n\n      "
    8.times do |a|
      print "|", a
    end
    print "\n\n"
  end
    
  def move(coordinates)  #does whatever its told, pieces need to check for valid moves
    pre_x = coordinates[0].to_i 
    pre_y = coordinates[1].to_i
    post_x = coordinates[2].to_i
    post_y = coordinates[3].to_i
    @grid[post_x][post_y] = @grid[pre_x][pre_y] #switch your piece onto the new spot
    new_cell = @grid[post_x][post_y]
    new_cell.position = [post_x][post_y]  #update piece with new coordinates
    @grid[pre_x][pre_y]= Cell.new([pre_x,pre_y])#create blank spot with coordinates in old spot
  end
  
  
 
  def find_kings #returns an array of the kings positions
    b_king_pos_a = ""
    b_king_pos_b = ""
    w_king_pos_a = ""
    w_king_pos_b = ""
    puts "  locating kings ..."
    8.times do |a| #locate the kings
      8.times do |b|
        if @grid[a][b].value == 'K'
          puts "king @ #{a}#{b}"
          if @grid[a][b].color == 'white'
            w_king_pos_a = a
            w_king_pos_b = b
            puts "located white king @ [#{a}][#{b}]"
          end
          if @grid[a][b].color == 'black'
            b_king_pos_a = a
            b_king_pos_b = b
            puts "located black king @ [#{b_king_pos_a}][#{b_king_pos_b}]"
          end
        end
      end
    end
    return ([w_king_pos_a,w_king_pos_b,b_king_pos_a,b_king_pos_b])
    
  end
  
  
  def in_check?(board,player1,player2,king_position)
    if player1.color != "white"
      player1,player2 = player2, player1
    end
    piece = ""
    catch :check do
    
    8.times do |c|  # for all the pieces on the board
      8.times do |d|
        if @grid[c][d].color == 'white'  # if they are white, see if they can move to the black kings position
          puts "Can #{@grid[c][d].value}.#{@grid[c][d].color} move to the black king?"
          piece = @grid[c][d]  
          if piece.moves([c,d,king_position[2],king_position[3]],board,player1) ##true if the piece can move to the black king
            puts "Black King is in CHECK!!!"
            if @grid[king_position[2]][king_position[3]].value == "K"  #this is for the error that is thrown during checkmate
            @grid[king_position[2]][king_position[3]].in_check = true
            end
            return true
            throw :check
          end
        end
          
        if @grid[c][d].color == 'black'
        puts "Can #{@grid[c][d].value} move to the white king?"
        piece = @grid[c][d]
        if piece.moves([c,d,king_position[0],king_position[1]],board,player2)
          check =  true
          puts "White King is in CHECK!!!"
          @grid[king_positiion[0]][king_position[1]].in_check = true
          return true
          throw :check
          end
          end
        end
       end
      end
    return false
  end
  
  
  
  
  def checkmate?(board, player1, player2, king_position)# if the king is surrounded by other colors, this might eat the pieces during check
    
    puts ""
    puts "checking for checkmate from Board#checkmate?"
    if @grid[king_position[0]][king_position[1]].in_check == true
      
      king_pos_a = king_position[0]
      king_pos_b = king_position[1]
    else
      king_pos_a = king_position[2]
      king_pos_b = king_position[3]
    if player1.color != "white"
      player1,player2 = player2, player1
    end
      [-1,0,1].each do |a|
        [-1,0,1].each do |b|
          puts " Checking for a check at king location#{king_pos_a+a}#{king_pos_b+b}"
          if (king_pos_a +a).between?(0,7) && (king_pos_b +b).between?(0,7) # if the king test position is between 0 and 7, bounds of the board
            if @grid[king_pos_a +a][king_pos_b + b].color != @grid[king_pos_a][king_pos_b].color  #is the cell unoccupied or not
              puts "moving king to #{king_pos_a + a} #{king_pos_b +b}"
              board.move([king_pos_a,king_pos_b,king_pos_a+a,king_pos_b+b]) #move the king to the possible positions
              check = in_check?(board,player1,player2,king_position)  #if that move is not going to be in check
              if check 
                board.move([king_pos_a +a,king_pos_b + b, king_pos_a, king_pos_b])#undo the move you just made in prep for next test move
                puts "The Board#checkmate? method detected a possible non Check move at #{king_pos_a +a} #{king_pos_b + b}"
                puts "...exiting the checkmate loop."
                return false
                    #this lets us know there is a possible move
                end
              board.move([king_pos_a+a,king_pos_b + b, king_pos_a, king_pos_b])#undo the move you just made in prep for next test move
          end
        end
      end
    end
   
    return true
    end
    end #of checkmate?
  end#of class



class Cell
  attr_accessor :position, :value, :color
  def initialize(position = [0,0],value = " ", color = "clear")
    @position = position
    @value = value
    @color = color
  end   
end

class Player
  attr_reader :color, :name
  def initialize(color)
    puts "Please enter your name:"
    name = gets.chomp
    @name = name
    @color = color
   end
end   

class GamePiece
  def jumpy?(first, last, x) #return true if move requires a jump
    (first+1..last-1).each do |a|
      return false if board.grid[x][a].value != " "
    end
    #unless cells in movement contain a value other than " " return true
  end
  
  def jumpx?(first,last, y )
    (first+1..last-1).each do |a|
      return false if board.grid[a][y].value != " "
    end
  end
  
  
end


class Pawn < GamePiece #single open move only for now
  attr_accessor :position, :color, :value
  def initialize(position, color, value = 'P')
    @position = position
    @color = color
    @value = value
  end
  def moves(new_position,board,player)# old, requested move coordinates as arrays [0,0][1,0]
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    #switch player 2 x values for testing, they move only 'backwards', this prevents alternate tests
    if player.color == 'black'
      pre_x, post_x = post_x, pre_x
      end
    if post_x == pre_x+1 #movement forward
      if post_y == pre_y #no lateral movement #regular move   
        return true if new_cell.value == " "  #only if its unoccupied
      elsif (post_y == pre_y-1) || (post_y == pre_y+1)#already forward  #one space sideways      ###attack move
        if  (new_cell.color != player.color) && (new_cell.color != 'clear')  #if its other players piece, not a blank
          return true
        end
      end
    end
    puts " --The Pawn cannot make that move"
    return false
  end
end


 


class Rook
  attr_accessor :position, :color, :value
  def initialize(position, color)
    @position = position
    @color = color
    @value = "R"
  end
  
  def jumpy?(first, last, x, board) #return true if move requires a jump, wont run high to low
    
    go = true
    puts "Testing rook movement for illegal jump sideways"
    ((first+1)..(last-1)).each do |a|
      puts a
      if board.grid[x][a].value != " "
        go = false 
      end
    end
    return go
    #unless cells in movement contain a value other than " " return true
  end
  
  def jumpx?(first, last, y , board )
    go = true
    puts "Testing rook movement for illegal jump forward/backward"

    (first+1..last-1).each do |a|
      if board.grid[a][y].value != " "
        go = false
      end
    end
    return go
  end
  
  def moves(new_position, board, player)
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    
    
    #this is a sideways move test
    if (pre_y == post_y && pre_x != post_x) || (pre_x == post_x  &&  pre_y != post_y)  #if the change is only in x or y(linear move)
      puts " rook linear movement dectected"
      if pre_y-post_y != 0 
        puts "Rook movement sideways detected "
        high = [pre_y,post_y].max  #rooks can move either direction, need to make values to iterate through in jump?
        low = [pre_y,post_y].min
        go = true
        if high-low > 1
          go = jumpy?(low,high,post_x, board ) # if more than one cell movement, there are no jumps
        end
        if board.grid[post_x][post_y].color != player.color
            puts "rook passed jump and other color test for sideways"
            return go  #only returns if no jumps and this
        end
      elsif post_x - pre_x != 0 #forward backward move
        go = true
        puts "rook forward/backward move detected"
        high= [post_x,pre_x].max
        low = [post_x,pre_x].min 
        if high - low > 1 #multi cell movement, check middle cells for piece
          go = jumpx?(low,high, post_y, board)
        end
        if board.grid[post_x][post_y].color != player.color
          puts "rook passed jump and color tests for fwd/bck"
          return go
        end
      end
    else 
      puts "only linear moves allowed for the Rook "
      return false
    end
    
    
  end
end


class Bishop
  attr_accessor :value, :color, :position  #color on pieces should be reader
  
  def initialize(position, color, value= "B")
    @position = position
    @color = color
    @value = value
  end
  

  
  def moves(new_position, board, player)
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    max_x = [new_position[0],new_position[2]].max
    max_y = [new_position[1],new_position[3]].max
    min_x = [new_position[0],new_position[2]].min
    min_y = [new_position[1],new_position[3]].min
    go = true
    
    if (max_x-min_x == max_y-min_y)
      puts "Bishop has detected a diagonal move"
      if post_x - pre_x > 0 
        x_increment = 1
      else
        x_increment = -1
      end
      if post_y - pre_y > 0
        y_increment = 1
      else
        y_increment = -1
      end
      x_counter = x_increment
      y_counter = y_increment
      
      (max_x - min_x).times do 
        puts "Bishop checking for possible illegal jumps@ board.grid#{[pre_x + x_counter]}#{[pre_y + y_counter]} "
        if board.grid[pre_x + x_counter][pre_y + y_counter].value != " "
          puts "illegal jump detected @ board.grid[#{pre_x + x_counter}][#{pre_y+y_counter}]"
          go = false
          end
        x_counter += x_increment
        y_counter += y_increment
        end
      if board.grid[post_x][post_y].color == player.color
        go = false
      end
      
      return go
    else
      puts "only diagonal moves allowed on Bishop"
      return false
    end
  end
end

class Knight
  attr_accessor :value, :position, :color
  
  def initialize(position, color, value = "k")
    @position= position
    @color = color
    @value = value
  end
  
  def moves(new_position, board, player)
  
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    max_x = [new_position[0],new_position[2]].max
    max_y = [new_position[1],new_position[3]].max
    min_x = [new_position[0],new_position[2]].min
    min_y = [new_position[1],new_position[3]].min
    go = true
    
    if ((max_x - min_x).abs == 2*(max_y - min_y).abs) || (2*(max_x - min_x).abs == (max_y - min_y).abs) # looks for a 2:1 relationship between x and y
      if board.grid[post_x][post_y].color != player.color
        if max_x - min_x <=2 && max_y-min_y <=2#2:1 relationships longer than the 2 cells were sneaking through
          return true
        end
      end
    else
      puts "Knight's one two : two one pattern not detected"
      return false
    end
    end
  end
  
class Queen
  attr_accessor :position, :color, :value
  
  def initialize (position, color, value = "Q")
    @position = position
    @color = color
    @value = value
   end
    def jumpy?(first, last, x, board) #return true if move requires a jump, wont run high to low
    
    go = true
    puts "Queen checking for illegal jumps sideways"
    ((first+1)..(last-1)).each do |a|
      puts a
      if board.grid[x][a].value != " "
        go = false 
      end
    end
    return go
    #unless cells in movement contain a value other than " " return true
  end
  
  def jumpx?(first, last, y , board )
    go = true
    puts "Queen checking for illegal fwd/bck jumps"
    (first+1..last-1).each do |a|
      if board.grid[a][y].value != " "
        go = false
      end
    end
    return go
  end
   def moves(new_position, board, player)
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    max_x = [new_position[0],new_position[2]].max
    max_y = [new_position[1],new_position[3]].max
    min_x = [new_position[0],new_position[2]].min
    min_y = [new_position[1],new_position[3]].min
    go = true
    
    if (max_x-min_x == max_y-min_y)
      puts "Queen diagonal move detected"
      if post_x - pre_x > 0 
        x_increment = 1
      else
        x_increment = -1
      end
      if post_y - pre_y > 0
        y_increment = 1
      else
        y_increment = -1
      end
      x_counter = x_increment
      y_counter = y_increment
      
      ((max_x - min_x)-1).times do 
        puts "Queen checking #{pre_x} + #{x_counter} || #{pre_y} + #{y_counter} for gamepiece"
        if board.grid[pre_x + x_counter][pre_y + y_counter].value != " "
          puts "Queen illegal diagonal jump detected"
          go = false
          end
        x_counter += x_increment
        y_counter += y_increment
        end
      if board.grid[post_x][post_y].color == player.color
        go = false
      end
      
      return go
      
    elsif (pre_y == post_y && pre_x != post_x) || (pre_x == post_x  &&  pre_y != post_y)  #if the change is only in x or y(linear move)
      puts "Queen linear movement dectected"
      if pre_y-post_y != 0 
        puts "left right movement changes on y "
        high = [pre_y,post_y].max  #rooks can move either direction, need to make values to iterate through in jump?
        low = [pre_y,post_y].min
        if high-low > 1
          go = jumpy?(low,high,post_x, board ) # if more than one cell movement, there are no jumps
          end
        if board.grid[post_x][post_y].color != player.color
            puts "passed jump and other color test"
            return go  #only returns if no jumps and this
            end
      elsif post_x - pre_x != 0 #forward backward move
        go = true
        puts "Queen forward/backward move detected"
        high= [post_x,pre_x].max
        low = [post_x,pre_x].min 
        if high - low > 1 #multi cell movement, check middle cells for piece
          go = jumpx?(low,high, post_y, board)
          end
        if board.grid[post_x][post_y].color != player.color
          puts "Queen passed jump and color tests"
          return go
          end
      end
    end
  end
end
    
    
class King
  attr_accessor :position, :color, :value, :in_check
  
  def initialize(postion, color, value = "K", in_check = false)
    @position = position
    @color = color
    @value = value
    @in_check = in_check
  end
  
  def moves(new_position, board, player)
    
    pre_x = new_position[0] 
    pre_y = new_position[1] 
    post_x = new_position[2]
    post_y = new_position[3]
    new_cell = board.grid[post_x][post_y] 
    max_x = [new_position[0],new_position[2]].max
    max_y = [new_position[1],new_position[3]].max
    min_x = [new_position[0],new_position[2]].min
    min_y = [new_position[1],new_position[3]].min
    if max_x - min_x <=1 &&  max_y-min_y <=1  #only one cell per x and y
      if board.grid[post_x][post_y].color != player.color
        return true
      end
    end
  end
end
  

    
class Game #players as a list of people
  attr_accessor :current_player, :other_player
  def initialize()
    player1 = Player.new('white')
    player2 = Player.new('black')
    @current_player = player1
    @other_player = player2
  end
  def generate_game_pieces(board)
    8.times do |a|
      board.grid[1][a] = Pawn.new([1,a],'white','@')
      board.grid[6][a] = Pawn.new([6,a],'black')
    end
      board.grid[0][0] = Rook.new([0,0],'white')
      board.grid[0][7] = Rook.new([0,7], 'white')
      board.grid[7][0] = Rook.new([7,0],'black')
      board.grid[7][7] = Rook.new([7,7], 'black')
      board.grid[0][2] = Bishop.new([0,2], 'white')
      board.grid[0][5] = Bishop.new([0,5], 'white')
      board.grid[7][2] = Bishop.new([7,2], 'black')
      board.grid[7][5] = Bishop.new([7,5], 'black')
      board.grid[0][1] = Knight.new([0,1], 'white')
      board.grid[0][6] = Knight.new([0,6], 'white')
      board.grid[7][1] = Knight.new([7,1], 'black')
      board.grid[7][6] = Knight.new([7,6], 'black')
      board.grid[0][3] = Queen.new([0,3], 'white')
      board.grid[7][3] = Queen.new([7,3], 'black')
      board.grid[0][4] = King.new([0,4], 'white')
      board.grid[7][4] = King.new([7,4], 'black')
      
    
  end
  
  def get_move
    puts "please enter the move as coordinates to move from, and coordinates to move to 1020"
    
    input = gets.chomp.split(//)
   
  end
  
  def translate_input(new_coord)
    x=new_coord[2].to_i
    y=new_coord[3].to_i
    a=new_coord[0].to_i
    b=new_coord[1].to_i
    return x,y,a,b
  end


  def call_move_on_piece(new_coord,board)
    x=new_coord[2].to_i
    y=new_coord[3].to_i
    a=new_coord[0].to_i
    b=new_coord[1].to_i
    piece = board.grid[a][b]
    puts "Checking to see if the piece you are moving is yours"
    if piece.color == @current_player.color #if its the players piece being moved
      puts "   ...and it is."
      puts "Checking for legal move"
      if piece.moves([a,b,x,y],board,@current_player)#if the move is allowed return true
        puts "Legal Movement Detected"
        return true #tell Game#play to call Board#move
      else
        puts "Illegal Movement Detected from Game#call_move_on_piece"
        end
    else
      puts "Thats not your piece to move #{@current_player.name}"
      puts ""
      return false
      
    end
  end  
  

  
  def play()
    puts "Welcome to Chess, would you like to load the saved game?"
    input = gets.chomp
    board = Board.new
    if input[0].downcase == 'y'
      board = Board.new("load")
    else
    
      generate_game_pieces(board)
    end
    go_nogo = [] #array for the check/checkmate method
    catch :gameover do
    while true
      board.display
      puts "#{@current_player.name}'s move"
      input = get_move
      print input
      if input[0] == 's'
        puts "calling board.save from Game#play"
        board.save
      end
      
      if call_move_on_piece(input,board)  #if this returns true switch the pieces
        puts "moving in Game#play"
        board.move(input)
      else
        puts "failed callmoveonpiece, not moving your piece"
      end
      puts ""
      puts "Checking for a check situation"
      
      check = board.in_check?(board,@current_player,@other_player,board.find_kings) #passing board so the board can check if a piece can move
      if check 
        puts "check from Game#play, calling checkmate?"
        if board.checkmate?(board,@current_player, @other_player, board.find_kings) 
          puts "\t\t\tgameover"
          throw :gameover
        end
      end
      puts ""
      puts ""
      puts ""
      @current_player, @other_player = @other_player, @current_player
    end
    end
  puts " Checkmate was detected.  Game over."
  end
end

require 'YAML'


game = Game.new
game.play
