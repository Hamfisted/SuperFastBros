package;

class Utils
{
  public static function getLevelPaths():Array<String>
  {
    var arr = new Array<String>();
    for ( i in 0...99 )
    {
      var s = Std.string(i);
      if (i < 10)
      {
        s = "0" + s;
      }

      var level = Reflect.field(AssetPaths, 'level${s}__oel');
      if (level != null)
      {
        arr.push(level);
      }
      else
      {
        break;
      }
    }
    return arr;
  }
}
