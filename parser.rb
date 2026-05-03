class Parser
  def initialize(texto)
    @tokens = texto.scan(/\d+|\+|\-|\*|\/|\^|\(|\)/)
    @pos = 0
  end

  def atual
    @tokens[@pos]
  end

  def consumir(esperado = nil)
    token = atual
    if esperado && token != esperado
      raise "Esperado '#{esperado}', encontrado '#{token}'"
    end
    @pos += 1
    token
  end

  def parse
    resultado = expressao
    raise "Expressão inválida" unless atual.nil?
    resultado
  end

  def expressao
    node = termo
    while ['+', '-'].include?(atual)
      op = consumir
      right = termo
      node = op == '+' ? ["soma", node, right] : ["subtracao", node, right]
    end
    node
  end

  def termo
    node = fator
    while ['*', '/'].include?(atual)
      op = consumir
      right = fator
      node = op == '*' ? ["multiplicacao", node, right] : ["divisao", node, right]
    end
    node
  end

  def fator
    potencia
  end

  def potencia
    node = unario
    if atual == '^'
      consumir('^')
      right = potencia
      node = ["potencia", node, right]
    end
    node
  end

  def unario
    if atual == '-'
      consumir('-')
      valor = primario
      return -valor if valor.is_a?(Integer)
      return ["negativo", valor]
    end
    primario
  end

  def primario
    token = atual
    raise "Fim inesperado" if token.nil?

    if token.match?(/\d+/)
      consumir
      return token.to_i
    end

    if token == '('
      consumir('(')
      node = expressao
      consumir(')')
      return node
    end

    raise "Token inválido: #{token}"
  end
end


puts "Digite uma expressão:"
entrada = gets.chomp

begin
  parser = Parser.new(entrada)
  resultado = parser.parse

  puts "Expressão aceita!"
  p resultado

rescue => e
  puts "Expressão rejeitada!"
  puts "Erro: #{e.message}"
end