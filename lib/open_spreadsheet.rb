# coding:utf-8
module OpenSpreadsheet
  def open_spreadsheet(file)
    if file
      case File.extname(file.original_filename)
      when ".csv"
        file
      else 
        raise "未知文件类型: #{file.original_filename}"
      end
    else
      raise "请选择要上传的CSV文件."
    end
  end
end