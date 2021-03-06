class SessionsController < ApplicationController
  skip_before_action :authenticate_admin!, [:new, :create, :destroy]
  skip_before_action :verify_authenticity_token

  def new
    redirect_back if member_signed_in?

    @page_title = "Login"
    set_meta_tags noindex: true, nofollow: true
  end

  def create
    @page_title = "Login"
    identifier = params[:identifier]
    password = params[:password]
    respond_to do |format|
      flag = true
      if identifier.present? && password.present?
        if member = Member.unscoped.where(accepted: true).where("student_number = ? OR email = ?", identifier, identifier).take.try(:authenticate, password)
          signin_member(member)
          cookies.permanent[:mtk] = "#{member.id}$#{member.remember_token}" if params[:remember_me] == '1'
          format.html { redirect_back notice: "You have successfully signed in" }
          format.json { render json: {
            access: member.max_restriction,
            member_id: member.id,
            member_full_name: member.full_name
            }
          }
          flag = false
        end
      end
      if flag
        flash.now[:alert] =  "Wrong email and password combination"
        format.html { render :new }
        format.json { render json: {access: 0} }
      end
    end
  end

  def destroy
    signout_member
    redirect_back
  end
end
