module HelpFunctions

  def digit?(char)
    char <= '9' and char >= '0'
  end

  def letter?(char)
    char <= 'Z' and char >= 'A'
  end

  def empty_row?(string)
    (string.length - 1).times do |i|
      if string[i] != " " then return false end
    end
    return true
  end

  def find_column(char)
    column = 0
    temporary = 'A'
    until temporary == char
      column += 1
      temporary.next!
    end
    column
  end

  def get_row(string)
    string.slice!(/[0-9]*/).to_i - 1
  end

  def get_column(string)
    string.slice!(/[A-Z]*/)
  end

  def is_f?(number)
    number.to_s.count('.') == 1
  end

end

module HelpEvaluation

  def adjust_formulas(string)
      new_one = string
      (string.length - 1).times do |i|
        if new_one[i] == '='
          new_one.sub!(new_one[i..new_one.index(')')],
                       new_one[i..new_one.index(')')].gsub!("\t", " "))
        end
      end
      new_one
    end

end



class Spreadsheet

  include HelpFunctions

  def initialize(argument = nil)
    @sheet = Sheet.new
    return unless argument != nil
    make_table = argument.split("\n")
    make_table.delete("")
    make_table.each {|x| if ! empty_row?(x) then @sheet.push_row(x) end}
    @to_s_state = ""
  end

  def empty?
    @sheet.null?
  end

  def cell_at(cell_index)
    check_the_index(cell_index)
    column = get_column(cell_index)
    row = get_row(cell_index)
    real_column = find_column(column)
    check_if_exists(row + 1, column,real_column)
    @sheet.get_element(row, real_column)
  end

  def [](cell_index)
    result_string = cell_at(cell_index)
    @sheet.evaluate(result_string).to_s
  end

  def to_s
    length = @sheet.table.length
    length.times do |i|
      @to_s_state << @sheet.print_row(i)
      if i != length - 1 then @to_s_state << "\n" end
    end
    @to_s_state
  end

  private

  def check_the_index(n)
    invalid_index = Error.new("Invalid cell index '#{n}'")
    raise invalid_index unless digit?(n[-1]) and letter?(n[0])
    double_check(n, invalid_index)
    n.length.times do |i|
      raise invalid_index unless digit?(n[i]) or letter?(n[i])
    end
  end

  def double_check(n, invalid_index)
    (n.length - 1).times do |i|
      if (digit?(n[i]) and letter?(n[i + 1]))
        raise invalid_index
      end
    end
  end

  def check_if_exists(row, column, real_column)
    invalid_index = Error.new("Cell '#{column}#{row}' does not exist")
    if @sheet.table.size < row or @sheet.table.first.size < real_column
      raise invalid_index
    end
  end

  module HelpWithRounding

  def calculate(string)
      formula = Formula.new(string)
      elements = formula.arguments
      elements.map! { |x| x = evaluate(x) }
      elements.map! { |x| x = x.round(2) }
      result = elements.reduce(formula.get_operation)
      round_number(result.to_s)
  end

  def round_number(number)
    behind = number[/[.][0-9]*/]
    if behind == ".0" or behind == ".00" or behind == nil
      return number[/[0-9]*/]
    end
    if behind.length >= 4
      round_tree_digits(number)
    else
      round_less_digits(number)
    end
  end

  def round_less_digits(text)
    front = text[/[0-9]*[.]/]
    behind = text[/[.][0-9]*/]

    front + behind[1..behind.length] + ("0" * (3 - behind.length))
  end

  def round_tree_digits(text)
    front = text[/[0-9]*[.]/]
    behind = text[/[.][0-9]*/]
    if behind[3] >= '5'
      return front + behind = behind[1..2].next!
    else
      front + behind[1..2]
    end
  end

end


  class Sheet

    include HelpFunctions
    include HelpWithRounding
    include HelpEvaluation

    def initialize
      @table = []
      @current_result = ""
    end

    def null?
      @table.length == 0
    end

    def push_row(array)
      row = array.strip.gsub(/  */, "\t")
      row = adjust_formulas(row)
      elements = row.split("\t")
      elements.delete("")
      @table << elements
    end

    def get_element(row, column)
      row = @table[row]
      row[column]
    end

    def table
      @table
    end

    def evaluate(string)
      case
      when (digit?(string[0]) or string[0] == '+' or string[0] == '-')
        string.count('.') == 1 ? string.to_f : string.to_i
      when string[0] == '='
        calculate(string.delete("="))
      else
        text?(string)
      end
    end

    def text?(string)
      if digit?(string[-1])
         column = get_column(string)
        real_column = find_column(column)
        row = get_row(string)
        evaluate(get_element(row, real_column))
      else
        string
      end
    end

    def print_row(index)
      @current_result = ""
      @table[index].each do |x|
        digit?(x[-1]) ? @current_result << round_number(evaluate(x).to_s)
         : @current_result << evaluate(x).to_s
        if x != @table[index].last then @current_result << "\t" end
      end
      @current_result
    end

  end

  begin
    rescue Spreadsheet::Error => e
      e.message
  end

  class Error < StandardError
  end

  class Formula

    OPERATIONS = { "ADD" => '+' ,"MULTIPLY" => '*',
                  "SUBTRACT" => '-',"DIVIDE" => '/',"MOD" => '%' }

    attr_accessor :arguments

    def initialize(string)
      @operation = ""
      @arguments = []
      check_for_unknown_function(string)
      convert(string)
    end

    def get_operation
      OPERATIONS[@operation].to_sym
    end

    def convert(string)
      helper = string.split("(")
      validate_expression(string[helper.first.length.. -1])
      @operation = helper.first
      helper.last.delete!(")")
      remove_white_spaces(helper.last.split(","))
    end

    def remove_white_spaces(array)
      array.each do |element|
        while element.include? " "
          element.sub!(/  */, "")
        end
        @arguments << element
      end
      validate_variables_first_check
      validate_variables_second_check
    end

    def check_for_unknown_function(s)
      unknown = Error.new("Unknown function '#{s.split("(").first}'")
      if(OPERATIONS.has_key?(s.split("(").first) == false)
        raise unknown
      end
    end

    def validate_expression(s)
      invalid_expression = Error.new("Invalid expression '#{s}'")
      if s[-1] != (")") or s[0] != ("(")
        raise invalid_expression
      end
    end

    def validate_variables_first_check
      variables = Error.new("Wrong number of arguments for #{@operation}
        : expected at least 2, got #{@arguments.size}")
      if @arguments.size < 2
        raise variables
      end
    end

    def validate_variables_second_check
      variables = Error.new("Wrong number of arguments for #{@operation}
        : expected 2, got #{@arguments.size}")
      if (@operation == "SUBTRACT" or @operation == "DIVIDE" or
         @operation == "MOD") and @arguments.size >= 3
        raise variables
      end
    end

  end

end
