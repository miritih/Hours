class EntriesController < ApplicationController
  include CSVDownload
  before_action :sort_params, :direction_params, only: [:index]

  helper_method :sort_params, :direction_params

  DATE_FORMAT = "%d/%m/%Y".freeze

  def index
    @user = User.find_by_slug(params[:user_id])
    @hours_entries = @user.hours.
                              page(params[:hours_pages]).
                              per(20).
                              order(sort_params << ' ' << direction_params)
    @mileages_entries = @user.mileages.page(
      params[:mileages_pages]).per(20).order(sort_params << ' ' << direction_params)

    respond_to do |format|
      format.html { @mileages_entries + @hours_entries }
      format.csv do
        send_csv(
          name: @user.name,
          hours_entries: @user.hours.by_date,
          mileages_entries: @user.mileages.by_date)
      end
    end
  end

  def destroy
    resource.destroy
    redirect_to user_entries_path(current_user) + "##{controller_name}",
                notice: t("entry_deleted.#{controller_name}")
  end

  def edit
    @entry_type = set_entry_type
  end

  private

  def set_entry_type
    params[:controller]
  end

  def sort_params
    Hour.column_names.include?(params[:sort]) ? params[:sort] : 'date'
  end

  def direction_params
    %w[asc desc].include?(params[:direction])? params[:direction] : 'asc'
  end

  def parsed_date(entry_type)
    Date.strptime(params[entry_type][:date], DATE_FORMAT)
  end
end
