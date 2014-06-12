module Humanize

  def humanize_second secs
    [[60, '秒'], [60, '分'], [24, '小时'], [1000, '天']].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

end