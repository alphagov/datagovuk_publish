class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :update], Dataset do |dataset|
      user.creator_of_dataset?(dataset) || user.in_organisation?(dataset.organisation)
    end
  end
end
