classdef (ConstructOnLoad) parameterChoiceEventData < event.EventData
   properties
      param
   end
   
   methods
      function data = parameterChoiceEventData(param)
         data.param = param;
      end
   end
end