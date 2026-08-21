class LabelsController < ApplicationController
    def index
        @labels = Label.all
    end

    def show
        @label = Label.find(params[:id])
    end

    def new
        @label = Label.new
    end

    def create
        @label = Label.new(label_params)

        if @label.save
            flash[:notice] = "Label was successfully created."
            redirect_to label_path(@label)
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @label = Label.find(params[:id])
    end

    def update
        @label = Label.find(params[:id])

        if @label.update(label_params)
            flash[:notice] = "Label was successfully updated."
            redirect_to label_path(@label)
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @label = Label.find(params[:id])
        @label.destroy
        flash[:notice] = "Label was successfully deleted."
        redirect_to labels_path
    end


    def label_params
        params.require(:label).permit(:name)
    end
end
