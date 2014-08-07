module Version
  def Version.compare first, second
    # split appversion to numbers
    first_numbers = first.split '.'
    second_numbers = second.split '.'

    # compare the numbers to determine which is greater
    [first_numbers.length, second_numbers.length].min.times do |index|
      diff = first_numbers[index].to_i <=> second_numbers[index].to_i
      return diff unless diff == 0
    end

    # when the common part is the same, return true if it's long
    first_numbers.length <=> second_numbers.length
  end
end

