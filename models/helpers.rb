helpers do
  def ajaxHelper 
    if request.xhr? then 
      # content_type 'application/json'
      puts "request is xhr"
      content_type :json
      @layout = false
    end
  end
end

