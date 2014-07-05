module Api::V1
  class ItemTypesController < Api::V1::ApiController

    load_and_authorize_resource :item_type, parent: false

    def index
      #~ if params[:ids].present?
        #~ @item_types = @item_types.find( params[:ids].split(",") )
      #~ end
      #~ render json: @item_types, each_serializer: serializer

      # Trying out Surus all_json method (needs postgresql >= 9.2)
      json = ItemType
      if params[:ids].present?
        json = json.where(id: params[:ids].split(","))
      end
      render text: "{ \"item_types\": #{json.all_json} }"
    end

    def show
      render json: @item_type, serializer: serializer
    end

    private

    def serializer
      Api::V1::ItemTypeSerializer
    end

  end
end
