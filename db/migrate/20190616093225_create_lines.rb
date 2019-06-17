class CreateLines < ActiveRecord::Migration[5.1]
  def change
    create_table :lines do |t|
      t.string :rang
      t.text :dossard
      t.string :fullname
      t.string :temps
      t.string :cat
      t.string :rangcat
      t.string :ecart
      t.string :ecartcat
      t.string :club
      t.string :vitesse
      t.string :tempsaukm
      t.string :page

      t.timestamps
    end
  end
end
