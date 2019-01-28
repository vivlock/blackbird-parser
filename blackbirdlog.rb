require_relative 'blocks'

class BlackBirdLog
  def initialize(filename)
    @blocks = Array.new
    process(filename)
  end

  def output
    for block in @blocks
      block.output
      puts ""
    end
  end

  def write_file(filename)
    # TODO: write this.output to a file
  end

  private

  def push(block)
    @blocks.push(block)
  end

  def process(filename)
    fileStr = File.read(filename)
    pieces = fileStr.split(/(Request Name:)|(Criterion:)/)

    cur = 0
    length = pieces.length

    while(cur < length)
      if(pieces[cur] == "Request Name:")
        # next index is a request block;
        push RequestBlock.new(pieces[cur + 1])
        cur += 2
      elsif(pieces[cur] == "Criterion:")
        # next index is criterion block;
        push CriterionBlock.new(pieces[cur + 1])
        cur += 2
      else
        push Block.new(pieces[cur])
        cur += 1
      end
    end
  end
end
