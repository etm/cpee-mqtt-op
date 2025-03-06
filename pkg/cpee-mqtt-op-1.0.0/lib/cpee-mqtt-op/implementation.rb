# This file is part of CPEE-MQTT-OP.
#
# CPEE-MQTT-OP is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# CPEE-MQTT-OP is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with CPEE-MQTT-OP (file LICENSE in the main directory).  If not,
# see <http://www.gnu.org/licenses/>.

require 'mqtt'
require 'riddl/server'
require 'riddl/client'

module CPEE
  module MQTT_OP

    SERVER = File.expand_path(File.join(__dir__,'implementation.xml'))

    class Value < Riddl::Implementation #{{{
      def response
        topic = @p[0].value
        value = @p[1].value
        mqtt  = @a[0]
        MQTT::Client.connect(mqtt) do |c|
          c.publish(topic,value)
        end
      end
    end #}}}

    class Time < Riddl::Implementation #{{{
      def response
        time  = @p[0].value
        topic = @p[1].value
        start = @p[2].value
        stop  = @p[3].value
        mqtt  = @a[0]
        cb    = @h['CPEE_CALLBACK']
        EM.defer do
          MQTT::Client.connect(mqtt) do |c|
            c.publish(topic,start)
            sleep time.to_f
            c.publish(topic,stop)
            Riddl::Client.new(cb).put if cb.is_a?(String)
          end
        end
        Riddl::Header.new('CPEE-CALLBACK','true')
      end
    end #}}}

    class Time2 < Riddl::Implementation #{{{
      def response
        time        = @p[0].value
        start_topic = @p[1].value
        start_value = @p[2].value
        stop_topic  = @p[3].value
        stop_value  = @p[4].value
        mqtt  = @a[0]
        cb    = @h['CPEE_CALLBACK']
        EM.defer do
          MQTT::Client.connect(mqtt) do |c|
            c.publish(start_topic,start_value)
            sleep time.to_f
            c.publish(stop_topic,stop_value)
            Riddl::Client.new(cb).put if cb.is_a?(String)
          end
        end
        Riddl::Header.new('CPEE-CALLBACK','true')
      end
    end #}}}

    class Wait < Riddl::Implementation #{{{
      def response
        start_topic = @p[0].value
        start_value = @p[1].value
        stop_topic  = @p[2].value
        stop_value  = @p[3].value
        mqtt  = @a[0]
        cb    = @h['CPEE_CALLBACK']
        EM.defer do
          MQTT::Client.connect(mqtt) do |c|
            c.publish(start_topic,start_value)
            continue = true
            while continue
              topic, message = c.get(stop_topic)
              continue = false if message == stop_value
            end
            Riddl::Client.new(cb).put if cb.is_a?(String)
          end
        end
        Riddl::Header.new('CPEE-CALLBACK','true')
      end
    end #}}}

    def self::implementation(opts)
      opts[:mqtt] ||= 'mqtt://localhost:1883/'
      opts[:self] ||= "http#{opts[:secure] ? 's' : ''}://#{opts[:host]}:#{opts[:port]}/"

      Proc.new do
        on resource do
          on resource 'value' do
            run Value, opts[:mqtt] if put 'value'
          end
          on resource 'time' do
            run Time, opts[:mqtt] if put 'time'
          end
          on resource 'time2' do
            run Time2, opts[:mqtt] if put 'time2'
          end
          on resource 'wait' do
            run Wait, opts[:mqtt] if put 'wait'
          end
        end
      end
    end

  end
end
