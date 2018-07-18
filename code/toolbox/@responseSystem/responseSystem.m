classdef responseSystem
    % Class for building a modular response system.
    %   Detailed explanation goes here
    
    properties
        keyBindings;
        gamePad;
    end
    
    methods
        function obj = responseSystem(keyBindings)
            % Construct an instance of this class
            %   Detailed explanation goes here
            obj.keyBindings = keyBindings;
            
            try
                obj.gamePad = GamePad();
            catch
                obj.gamePad = [];
            end
        end
        
        function response = checkResponse(obj)
            key = obj.checkKeys();
            if ~isempty(key)
                response = obj.keyToResponse(key);
            else
                response = {};
            end
        end
        
        function response = waitForResponse(obj)
            response = [];
            while isempty(response)
                key = checkKeys(obj);
                if ~isempty(key)
                    response = obj.keyToResponse(upper(key));
                else
                    response = {};
                end
            end
        end
        
        function key = checkKeys(obj)
            key = {};
            key = [key, obj.getKey_keyboard];
            if ~isempty(obj.gamePad)
                key = [key, obj.getKey_GamePad(obj.gamePad)];
            end
            key = upper(key);
        end
        
        function response = keyToResponse(obj, key)
            response = {};
            for k = key
                if isKey(obj.keyBindings,k)
                    response = [response, obj.keyBindings(k{:})];
                end
            end
        end
    end
    
    methods (Static)
        button = getKey_GamePad(gamePad)
        key = getKey_keyboard
        key = getKey_MGL
    end
end