module Humanize

  def humanize_second secs
    [[60, '秒'], [60, '分'], [24, '小时'], [1000, '天']].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse[0..-2].join(' ')
  end

  def seconds_to_human_minutes secs
    secs = 60 if secs < 60 #不足一分钟设置一分钟，否则compact[1..-1]会出错

    [[60, '秒'], [60, '分'], [24, '小时'], [1000, '天']].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact[1..-1].reverse.join(' ')
  end

end
