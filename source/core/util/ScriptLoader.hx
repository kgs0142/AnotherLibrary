package core.util;

/**
 * Load script files (hscript, xml...) as dynamically as possible.
 * @author User
 */
class ScriptLoader
{
    private static var ms_Instance:ScriptLoader;
    
    public function new() 
    {
        
    }

    public static function Get() : ScriptLoader
    {
        if (ms_Instance == null)
        {
            ms_Instance = new ScriptLoader();
        }
        
        return ms_Instance;
    }
}