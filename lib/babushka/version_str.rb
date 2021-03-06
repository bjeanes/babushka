module Babushka
  class VersionStr
    include Comparable
    attr_reader :pieces, :operator, :version
    GemVersionOperators = %w[= == != > < >= <= ~>].freeze

    def <=> other
      other = other.to_version unless other.is_a? VersionStr
      max_length = [pieces.length, other.pieces.length].max
      (0...max_length).to_a.pick {|index|
        result = compare_pieces pieces[index], other.pieces[index]
        result unless result == 0
      } || 0
    end

    def initialize str
      @operator, @version = str.strip.scan(/^([^\s\w\-\.]+)?\s*([\w\-\.]+)$/).first

      if !(@operator.nil? || GemVersionOperators.include?(@operator))
        raise ArgumentError, "VersionStr.new('#{str}'): invalid operator '#{@operator}'."
      elsif @version.nil?
        raise ArgumentError, "VersionStr.new('#{str}'): couldn't parse a version number."
      else
        @pieces = @version.strip.scan(/\d+|[a-zA-Z]+|\w+/).map {|piece|
          piece[/^\d+$/] ? piece.to_i : piece
        }
        @operator = '==' if @operator.nil? || @operator == '='
      end
    end

    def to_s
      @operator == '==' ? @version : "#{@operator} #{@version}"
    end

    define_method "!=" do |other|
      !(self == other)
    end

    define_method "~>" do |other|
      (self >= other) && pieces.starts_with?(other.pieces[0..-2])
    end

    private

    def compare_pieces this, that
      if this.is_a?(String) ^ that.is_a?(String)
        this.is_a?(String) ? -1 : 1
      else
        (this || 0) <=> (that || 0)
      end
    end
  end
end
