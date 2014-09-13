class AddAttachmentToLandings < ActiveRecord::Migration
  def change
    add_attachment :landings, :cover_ipad
    add_attachment :landings, :cover_ipad_retina
  end
end
