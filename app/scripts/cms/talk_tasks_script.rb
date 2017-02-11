require 'digest/md5'
class Cms::TalkTasksScript < Cms::Script::Publication
  def exec
    tasks = Cms::TalkTask.select(:id).order(:id)
    tasks = tasks.where(site_id: Script.options[:site_id]) if Script.options && Script.options[:site_id]
    Script.total tasks.size

    tasks.each do |v|
      task = Cms::TalkTask.find_by(id: v[:id])
      next unless task

      begin
        Script.current
clean_statics = Zomeki.config.application['sys.clean_statics']
if clean_statics
        if File.exist?("#{task.path}.mp3")
          File.delete("#{task.path}.mp3")
          info_log "DELETED: #{task.path}.mp3"
        end
        rs = true
else
        if ::File.exist?(task.path)
          rs = make_sound(task)
        else
          rs = true
        end
end
        Script.success if rs
        task.destroy
        raise "MakeSoundError" unless rs
      rescue Script::InterruptException => e
        raise e
      rescue Exception => e
        puts "#{e}: #{task.path}"
        Script.error "#{e}: #{task.path}"
        #error_log "#{e} #{task.path}"
      end
    end
  end

  def make_sound(task)
    content = ::File.new(task.path).read
    #hash = Digest::MD5.new.update(content.to_s).to_s
    #return true if hash == task.content_hash && ::File.exist?("#{task.path}.mp3")

    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make(content, {:site_id => task.site_id})
    mp3 = jtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0
    FileUtils.mv(mp3[:path], "#{task.path}.mp3")
    ::File.chmod(0644, "#{task.path}.mp3")
    return true
  end
end