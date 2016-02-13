module Collector
  class LabelsController < CollectorController
    before_action :set_label, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, only: [:edit, :update, :destroy]

    # GET /labels
    # GET /labels.json
    def index
      respond_to do |format|
        format.html do
          if (q = params[:q])
            where = [
              'name LIKE ? OR description LIKE ? OR twitter LIKE ? OR ameblo LIKE ?',
              *["%#{q.gsub(/([_%])/, '\\\\\1')}%"] * 4
            ]
          end
          @labels = Label
            .order(params.fetch(:order, :description))
            .where('id >= ?', 0)
            .where(where)
            .page(params[:page])
            .per(100)
        end
        format.json do
          @labels = Label.where.not(index_number: nil)
        end
      end
    end

    def all
      @labels = Label.where('id >= ?', 0).all
      respond_to do |format|
        format.json
      end
    end

    # GET /labels/1
    # GET /labels/1.json
    def show
    end

    # GET /labels/new
    def new
      @label = Label.new
    end

    # GET /labels/1/edit
    def edit
    end

    # POST /labels
    # POST /labels.json
    def create
      @label = Label.new(label_params)

      respond_to do |format|
        if @label.save
          format.html { redirect_to collector_label_path(@label), notice: 'Label was successfully created.' }
          format.json { render :show, status: :created, location: @label }
        else
          format.html { render :new }
          format.json { render json: @label.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /labels/1
    # PATCH/PUT /labels/1.json
    def update
      respond_to do |format|
        if @label.update(label_params)
          format.html { redirect_to collector_label_path(@label), notice: 'Label was successfully updated.' }
          format.json { render :show, status: :ok, location: @label }
        else
          format.html { render :edit }
          format.json { render json: @label.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /labels/1
    # DELETE /labels/1.json
    def destroy
      @label.destroy
      respond_to do |format|
        format.html { redirect_to collector_labels_url, notice: 'Label was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_label
      @label = Label.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def label_params
      params.require(:label).permit(:name, :index_number, :description, :url, :twitter, :ameblo, :tags)
    end
  end
end
