class Datasets::FoiContactsController < ApplicationController
  before_action :current_dataset

  def new
    @foi_contact = Dataset::FoiContact.new
  end

  def edit
    @foi_contact = Dataset::FoiContact.new(
      foi_name:  current_dataset.foi_name,
      foi_email: current_dataset.foi_email,
      foi_phone: current_dataset.foi_phone
    )
  end

  def update
    @foi_contact = Dataset::FoiContact.new(foi_contact_params)

    if @foi_contact.valid?
      @dataset.update(foi_contact_params)
      redirect_to dataset_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

  def create
    @foi_contact = Dataset::FoiContact.new(foi_contact_params)

    if @foi_contact.valid?
      @dataset.update(foi_contact_params)
      redirect_to new_dataset_licence_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  private

  def foi_contact_params
    params.require(:dataset_foi_contact).permit(:foi_name, :foi_email, :foi_phone)
  end

  def current_dataset
    @dataset ||= Dataset.find_by(uuid: params[:uuid])
  end
end
