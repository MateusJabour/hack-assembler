require_relative './code.rb'
require_relative './parser.rb'
require_relative './symbol_table.rb'

PREDEFINED_SYMBOLS = {
  'R0' => 0,
  'R1' => 1,
  'R2' => 2,
  'R3' => 3,
  'R4' => 4,
  'R5' => 5,
  'R6' => 6,
  'R7' => 7,
  'R8' => 8,
  'R9' => 9,
  'R10' => 10,
  'R11' => 11,
  'R12' => 12,
  'R13' => 13,
  'R14' => 14,
  'R15' => 15,
  'SP' => 0,
  'LCL' => 1,
  'ARG' => 2,
  'THIS' => 3,
  'THAT' => 4,
  'SCREEN' => 0x4000,
  'KBD'    => 0x6000
}

MAX_PROGRAM_SIZE = (2**15) - 1

def add_predefined_symbols(symbols)
  PREDEFINED_SYMBOLS.each do |k, v|
    symbols.add_new_symbol(k, v)
  end
end

def store_labels(input, symbols)
  address = 0

  parser = Parser.new(input)

  while parser.has_more_commands?
    parser.advance

    case parser.command_type
    when Parser::L_COMMAND
      symbols.add_new_symbol(parser.symbol, address)
    else
      address += 1
    end
  end

  raise "Program is too large: #{address} > #{MAX_PROGRAM_SIZE}" if address >= MAX_PROGRAM_SIZE
end

def generate_code(input, symbols, output)
  variable_address = 16
  parser = Parser.new(input)

  while parser.has_more_commands?
    parser.advance

    case parser.command_type
    when Parser::A_COMMAND
      symbol = parser.symbol

      begin
        output.puts '0%015b' % symbol
      rescue ArgumentError
        unless symbols.symbol_initialized?(symbol)
          symbols.add_new_symbol(symbol, variable_address)
          variable_address += 1
        end

        address = symbols.get_address(symbol)
        output.puts '0%015b' % address
      end
    when Parser::C_COMMAND
      output.puts [
        '111',
        Code.comp(parser.comp),
        Code.dest(parser.dest),
        Code.jump(parser.jump)
      ].join
    end
  end
end

def main
  symbols = SymbolTable.new
  add_predefined_symbols(symbols)

  path = ARGV[0]
  input = ARGF.read
  fileout = File.new(path[0..-5] + '.hack', 'w')
  store_labels(input, symbols)
  generate_code(input, symbols, fileout)
end

main
