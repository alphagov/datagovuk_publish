class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
    end

    # Publishers can always create a dataset
    can :create, Dataset

    can :read, Dataset do |dataset|
      # User can read a dataset if they are a creator, or
      # in an organisation shared by the dataset
      user.id == dataset.creator_id ||
        user.in_organisation(dataset.organisation)
    end

    can :update, Dataset do |dataset|
      # User can update a dataset if they are a creator, or
      # in an organisation shared by the dataset
      user.id == dataset.creator_id ||
        user.in_organisation(dataset.organisation)
    end

    can :delete, Dataset do |_|
      # Only sysadmins should be able to delete datasets
      user.admin?
    end

  end
end
