class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authorize, :set_i18n_locale_from_params
  protect_from_forgery with: :exception

  protected
    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          I18n.locale = params[:locale]
        else
          flash.now[:notice] =
            "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
    end

    def authorize
      unless User.find_by(id:session[:user_id])
      redirect_to login_url, notice: "Пожалуйста, пройдите авторизацию"
    end

  end
end
end
