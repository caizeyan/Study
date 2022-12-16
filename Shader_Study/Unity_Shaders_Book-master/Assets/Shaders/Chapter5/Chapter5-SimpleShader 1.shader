// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'



Shader "CZY/Simple Shader" {
	Properties{
	    _Color("Color",COLOR) = (1,1,1,1)
	}
	
	SubShader{

	    Pass{
	        CGPROGRAM
	        
	        #pragma vertex vert
	        #pragma fragment frag
	        
	        float4 _Color;
	        
	        struct a2v {
	            float4 vertex : POSITION;
	            float3 normal : NORMAL;
	            float4 texcoord : TEXCOORD0;
	        };
	        
	        struct v2f{
	            float4 pos : SV_POSITION;
	            float3 color : COLOR0;
	        };
	
          
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal*0.5 + float3(0.5,0.5,0.5);
                o.color *= _Color;
                return o; 
            }
            
            float4 frag(v2f i):SV_TARGET{
                return float4(i.color,1);
            }
                	        
	        ENDCG
	    }
	}
	
	Fallback "VertexLit"
}
