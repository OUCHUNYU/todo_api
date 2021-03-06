class ProjectsController < ApplicationController

  def create
    user = User.find_by(hash_id: create_action_params[:hash_id])
    if user
      reconstructed_params = {
        name:        create_action_params[:name],
        description: create_action_params[:description]
      }
      new_project = user.projects.new(reconstructed_params)
      if new_project.valid?
        user.save
        if user.position_order
          user.position_order += new_project.id.to_s + ","
          # new_order = user.position_order + new_project.id
          # user.update_attributes(position_order: new_order)
        else
          user.position_order = new_project.id.to_s + ","
        end
        user.save
        project_arr = User.render_projects_in_order(user)
        render json: project_arr
      else
        render json: { message: "something went wrong" }
      end
    else
        render json: { message: "user not found" }
    end
  end

  def show
    project = Project.find_by(id: params[:id])
    if project
      task_groups = Project.render_tasks_in_order(project)
      render json: task_groups
    else
      render json: { message: "project not found" }
    end
  end

  def update
    project = Project.find_by(id: params[:id])
    if project
      if project.update_attributes(update_action_params)
        project.save
        render json: User.render_projects_in_order(project.user)
      else
        render json: { message: "something went wrong" }
      end
    else
      render json: { message: "project not found" }
    end
  end

  def destroy
    user = User.find_by(hash_id: params[:hash_id])
    if user
      project = user.projects.find(params[:id])
      if project
        user.update_attributes(position_order: params[:order_string])
        project.destroy
        project_arr = User.render_projects_in_order(user)
        render json: project_arr
      else
        render json: { message: "project not found" }
      end
    else
      render json: { message: "Request denied" }
    end
  end

  def update_task_order
    project = Project.find_by(id: params[:project_id])
    if project && params[:list_id] && params[:order_string]
      Project.update_task_list_order(project, params[:list_id], params[:order_string])
      project_arr = Project.render_tasks_in_order(project)
      render json: project_arr
    else
      render json: { message: "something went wrong" }
    end
  end

  private

  def create_action_params
    params.permit(:hash_id, :name, :description)
  end

  def update_action_params
    params.permit(:name, :description, :archive)
  end

end
