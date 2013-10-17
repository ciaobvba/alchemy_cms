module Alchemy
  module Admin
    class TagsController < ResourcesController
      before_filter :load_tag, :only => [:edit, :update, :destroy]

      def index
        @tags = ActsAsTaggableOn::Tag.where(
          "name LIKE '%#{params[:query]}%'"
        ).page(params[:page] || 1).per(per_page_value_for_screen_size).order("name ASC")
      end

      def new
        @tag = ActsAsTaggableOn::Tag.new
      end

      def create
        @tag = ActsAsTaggableOn::Tag.create(tag_params)
        render_errors_or_redirect @tag, admin_tags_path, _t('New Tag Created')
      end

      def edit
        @tags = ActsAsTaggableOn::Tag.order("name ASC").to_a - [@tag]
      end

      def update
        if tag_params[:merge_to]
          @new_tag = ActsAsTaggableOn::Tag.find(tag_params[:merge_to])
          Tag.replace(@tag, @new_tag)
          operation_text = _t('Replaced Tag %{old_tag} with %{new_tag}') % {:old_tag => @tag.name, :new_tag => @new_tag.name}
          @tag.destroy
        else
          @tag.update_attributes(tag_params)
          @tag.save
          operation_text = _t(:successfully_updated_tag)
        end
        render_errors_or_redirect @tag, admin_tags_path, operation_text
      end

      def destroy
        if request.delete?
          @tag.destroy
          flash[:notice] = _t(:successfully_deleted_tag)
        end
        do_redirect_to admin_tags_path
      end

      def autocomplete
        items = ActsAsTaggableOn::Tag.where(['LOWER(name) LIKE ?', "#{params[:term].downcase}%"])
        render :json => json_for_autocomplete(items, :name)
      end

    private

      def load_tag
        @tag = ActsAsTaggableOn::Tag.find(params[:id])
      end

      def tag_params
        @tag_params ||= params.require(:tag).permit(:name, :merge_to)
      end

    end
  end
end