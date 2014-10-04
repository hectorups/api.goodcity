module Api::V1
  class OffersController < Api::V1::ApiController

    before_filter :eager_load_offer, except: [:index, :create]
    load_and_authorize_resource :offer, parent: false

    resource_description do
      short 'List, create, update and delete offers.'
      formats ['js']
      error 401, "Unauthorized"
      error 404, "Not Found"
      error 500, "Internal Server Error"
      description <<-EOS
        == Description
      EOS
    end

    def_param_group :offer do
      param :offer, Hash, required: true do
        param :language, I18n.available_locales.map(&:to_s), desc: "Offer language. If not set, defaults to API header language."
        param :state_event, Offer.valid_events, desc: "Fires the state transition (if allowed) for this offer."
        param :origin, String, desc: "Not yet used"
        param :stairs, [true, false], desc: "Does offer collection involve using stairs?"
        param :parking, [true, false], desc: "Is parking provided?"
        param :estimated_size, String, desc: "How big is the item?"
        param :notes, String, desc: "Not yet used"
        param :saleable, [true, false], desc: "Can these items be sold?"
        param :reviewed_by_id, Integer, allow_nil: true, desc: "User id of reviewer who is looking at the offer. Can only be set by reviewers."
      end
    end

    api :POST, '/v1/offers', "Create an offer"
    param_group :offer
    def create
      @offer = Offer.new(offer_params)
      @offer.created_by = current_user
      if @offer.save
        render json: @offer, serializer: serializer, status: 201
      else
        render json: @offer.errors.to_json, status: 500
      end
    end

    api :GET, '/v1/offers', "List all offers"
    param :ids, Array, of: Integer, desc: "Filter by offer id e.g. ids = [1,2,3,4]"
    param :state, Offer.valid_states, desc: "Filter by offer state e.g. state=draft"
    def index
      @offers = @offers.with_eager_load # this maintains security
      @offers = @offers.find(params[:ids].split(",")) if params[:ids].present?
      @offers = @offers.by_state(params['state']) if params['state']
      render json: @offers, each_serializer: serializer
    end

    api :GET, '/v1/offers/1', "List an offer"
    description "Returns json formatted offer details"
    def show
      render json: @offer, serializer: serializer
    end

    api :PUT, '/v1/offers/1', "Update an offer"
    param_group :offer
    def update
      @offer.update_attributes(offer_params)
      @offer.update_saleable_items if params[:offer][:saleable]
      render json: @offer, serializer: serializer
    end

    api :DELETE, '/v1/offers/1', "Delete an offer"
    description "If an offer is in draft state it will be destroyed. Any other state and it will be marked as deleted but remain recoverable."
    def destroy
      @offer.draft? ? @offer.really_destroy! : @offer.destroy
      render json: {}
    end

    private

    def eager_load_offer
      @offer = Offer.with_eager_load.find(params[:id])
    end

    def offer_params
      attributes = [:language, :origin, :stairs, :parking, :estimated_size, :notes, :state_event, :saleable]
      attributes << :reviewed_by_id if can?(:review, @offer)
      params.require(:offer).permit(attributes)
    end

    def serializer
      Api::V1::OfferSerializer
    end

  end
end
