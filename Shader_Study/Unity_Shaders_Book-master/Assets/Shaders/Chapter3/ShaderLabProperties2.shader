Shader "CZY/ShaderLabProperties"
{
    Properties
    {
        _Int ("int",Int) = 2
        _Float("float",Float) = 2.3
        _Range("Range",Range(0,5)) = 3
        _Color("Color",Color) = (1,1,1,1)
        _Vector("Vector",Vector) = (2,2,2,2)
        _2D("2D",2D) = ""{}
        _Cube("Cube",Cube) = ""{}
        _3D("3D",3D) = ""{}
    }
    SubShader
    {
        Pass
        {
          
        }
    }
    	FallBack "Diffuse"

}
