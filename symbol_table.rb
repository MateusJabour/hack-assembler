class SymbolTable
  def initialize
    @symbols = Hash.new
  end

  def symbol_initialized?(symbol)
    symbols.has_key?(symbol)
  end

  def add_new_symbol(symbol, address)
    symbols[symbol] = address
  end

  def get_address(symbol)
    symbols.fetch(symbol)
  end

  private

  attr_reader :symbols
end
