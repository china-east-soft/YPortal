class ChangeAttachmentToAdvertises < ActiveRecord::Migration
  def change
    remove_attachment :landings, :cover
    add_attachment :landings, :cover_iphone
    add_attachment :landings, :cover_iphone2x
    add_attachment :landings, :cover_iphone586
    add_attachment :landings, :cover_andriod
  end
end
