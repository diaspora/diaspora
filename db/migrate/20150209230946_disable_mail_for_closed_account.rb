class DisableMailForClosedAccount < ActiveRecord::Migration[4.2]
  def up
    User.joins(:person).where(people: {closed_account: true}).update_all(disable_mail: true)
  end

  def down
    User.joins(:person).where(people: {closed_account: true}).update_all(disable_mail: false)
  end
end
