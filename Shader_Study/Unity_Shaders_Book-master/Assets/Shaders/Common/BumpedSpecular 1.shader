// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Bumped Specular2"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_Bump("Bump",2D) = "bump" {}
		_Specular("Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,255)) = 20
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Geometry" "RenderType" = "Opaque"
		}
		Pass
		{
			Tags
			{
				"LightMode"="ForwardBase"
			}
			CGPROGRAM
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			//#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag


			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Bump;
			float4 _Bump_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex :POSITION;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(unity_MatrixMVP,v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bump);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float4 worldTangent = mul(unity_ObjectToWorld, v.tangent);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 bumpTanget = cross(worldNormal, worldTangent) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, bumpTanget.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, bumpTanget.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, bumpTanget.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 adobe = tex2D(_MainTex, i.uv.xy) * _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * adobe;

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 bump = UnpackNormal(tex2D(_Bump, i.uv.zw));
				bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(float3(dot(bump, i.TtoW0.xyz), dot(bump, i.TtoW1.xyz), dot(bump, i.TtoW2.xyz)));
				fixed3 diffuse = _LightColor0 * adobe * saturate(dot(bump, worldLight));

				fixed3 halfView = normalize(worldLight + worldView);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(bump, halfView)), _Gloss);
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)
				return fixed4(ambient + (diffuse + specular) * atten, 1);

				//return fixed4(ambient+(diffuse+specular)*atten,1);
			}
			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode"="ForwardAdd"
			}
			Blend One One
			CGPROGRAM
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Bump;
			float4 _Bump_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex :POSITION;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_Target;
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityWorldToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bump);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float4 worldTangent = mul(unity_ObjectToWorld, v.tangent);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 bumpTanget = cross(worldNormal, worldTangent) * worldTangent.w;
				o.TtoW0 = float4(worldTangent.x, bumpTanget.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, bumpTanget.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, bumpTanget.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(o)
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 adobe = tex2D(_MainTex, i.uv.xy) * _Color;

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 bump = UnpackNormal(tex2D(_Bump, i.uv.zw));
				bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(float3(dot(bump, i.TtoW0.xyz), dot(bump, i.TtoW1.xyz), dot(bump, i.TtoW2.xyz)));
				fixed3 diffuse = _LightColor0 * adobe * saturate(dot(bump, worldLight));

				fixed3 halfView = normalize(worldLight + worldView);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(bump, halfView)), _Gloss);
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

				return fixed4((diffuse + specular) * atten, 1);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
