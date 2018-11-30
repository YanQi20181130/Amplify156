// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "YQ/car"
{
	Properties
	{
		_BaseOcclusion("Base Occlusion", Range( 0 , 1)) = 0
		_CoatNormal("Coat Normal", 2D) = "bump" {}
		_CoatBump("Coat Bump", Range( 0 , 1)) = 0
		_CoatAmount("Coat Amount", Range( 0 , 1)) = 0
		_CoatSmoothness("Coat Smoothness", Range( 0.05 , 1)) = 0
		_Specintensity("Spec intensity", Float) = 1
		_maincolor("main color", Color) = (0,0,0,0)
		_maintexture("main texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _maincolor;
		uniform sampler2D _maintexture;
		uniform float4 _maintexture_ST;
		uniform float _CoatBump;
		uniform sampler2D _CoatNormal;
		uniform float4 _CoatNormal_ST;
		uniform float _Specintensity;
		uniform float _CoatSmoothness;
		uniform float _CoatAmount;
		uniform float _BaseOcclusion;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s332 = (SurfaceOutputStandard ) 0;
			float2 uv_maintexture = i.uv_texcoord * _maintexture_ST.xy + _maintexture_ST.zw;
			s332.Albedo = ( _maincolor * tex2D( _maintexture, uv_maintexture ) ).rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			s332.Normal = ase_worldNormal;
			s332.Emission = float3( 0,0,0 );
			s332.Metallic = 0.0;
			s332.Smoothness = 0.0;
			s332.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi332 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g332 = UnityGlossyEnvironmentSetup( s332.Smoothness, data.worldViewDir, s332.Normal, float3(0,0,0));
			gi332 = UnityGlobalIllumination( data, s332.Occlusion, s332.Normal, g332 );
			#endif

			float3 surfResult332 = LightingStandard ( s332, viewDir, gi332 ).rgb;
			surfResult332 += s332.Emission;

			SurfaceOutputStandardSpecular s166 = (SurfaceOutputStandardSpecular ) 0;
			s166.Albedo = float3( 0,0,0 );
			float2 uv_CoatNormal = i.uv_texcoord * _CoatNormal_ST.xy + _CoatNormal_ST.zw;
			s166.Normal = WorldNormalVector( i , UnpackScaleNormal( tex2D( _CoatNormal, uv_CoatNormal ), _CoatBump ) );
			s166.Emission = float3( 0,0,0 );
			float3 temp_cast_1 = (_Specintensity).xxx;
			s166.Specular = temp_cast_1;
			s166.Smoothness = _CoatSmoothness;
			s166.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi166 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g166 = UnityGlossyEnvironmentSetup( s166.Smoothness, data.worldViewDir, s166.Normal, float3(0,0,0));
			gi166 = UnityGlobalIllumination( data, s166.Occlusion, s166.Normal, g166 );
			#endif

			float3 surfResult166 = LightingStandardSpecular ( s166, viewDir, gi166 ).rgb;
			surfResult166 += s166.Emission;

			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode279 = ( 0.05 + 1.0 * pow( 1.0 - fresnelNdotV279, 5.0 ) );
			float lerpResult306 = lerp( i.vertexColor.r , 1.0 , _BaseOcclusion);
			float3 lerpResult208 = lerp( surfResult332 , surfResult166 , ( ( fresnelNode279 * _CoatAmount ) * lerpResult306 ));
			c.rgb = lerpResult208;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
0;752;1102;276;40.39154;-952.5888;2.700279;True;False
Node;AmplifyShaderEditor.CommentaryNode;280;-645.4806,1257.888;Float;False;1024.147;552.1847;Simple fresnel blend;11;47;279;301;238;307;296;299;298;308;306;237;Blend Factor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-283.3389,1658.847;Float;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-623.5804,1560.398;Float;False;Property;_CoatAmount;Coat Amount;15;0;Create;True;0;0;False;0;0;0.564;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;281;1158.15,1218.88;Float;False;1016.546;470.1129;This mirror layer that to mimc a coating layer;6;172;166;171;211;180;319;Coating Layer (Specular);1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-624.0447,1685.243;Float;False;Property;_BaseOcclusion;Base Occlusion;4;0;Create;True;0;0;False;0;0;0.489;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;301;-288.3418,1490.649;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;279;-596.1832,1308.718;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;306;-5.898457,1657.418;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;1305.684,1322.961;Float;False;Property;_CoatBump;Coat Bump;14;0;Create;True;0;0;False;0;0;0.231;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-257.3932,1397.812;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;334;1400.627,914.8605;Float;True;Property;_maintexture;main texture;22;0;Create;True;0;0;False;0;None;b297077dae62c1944ba14cad801cddf5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;333;1496.727,788.3976;Float;False;Property;_maincolor;main color;21;0;Create;True;0;0;False;0;0,0,0,0;0.2924528,0.2092692,0.009656467,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;172;1596.169,1551.392;Float;False;Property;_CoatSmoothness;Coat Smoothness;16;0;Create;True;0;0;False;0;0;0.907;0.05;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;1671.837,1459.224;Float;False;Property;_Specintensity;Spec intensity;19;0;Create;True;0;0;False;0;1;2.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;171;1582.135,1270.831;Float;True;Property;_CoatNormal;Coat Normal;13;0;Create;True;0;0;False;0;None;0bebe40e9ebbecc48b8e9cfea982da7e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;231.0996,1464.722;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;1824.383,910.5694;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;166;1919.696,1353.019;Float;False;Specular;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;319;2117.224,1583.155;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;293;-611.7687,-557.9827;Float;False;2602.156;1370.458;Comment;1;1;Base Layer With Dual Toning Flakes;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomStandardSurface;332;1954.879,841.0522;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-1943.947,-186.6538;Float;False;Property;_bias;bias;20;0;Create;True;0;0;False;0;0;0.03;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;296;-270.6724,1311.369;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-1774.515,-61.7677;Float;False;Property;_power;power;17;0;Create;True;0;0;False;0;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;324;2671.366,-7.801315;Float;False;Lerp White To;-1;;3;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;227;745.086,-103.8213;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;458.2278,706.8754;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;232;793.2447,607.6343;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;263;-528.714,511.8733;Float;False;Property;_FlakesColor2;Flakes Color 2;8;0;Create;True;0;0;False;0;1,0.9310344,0,0;0.6415094,0.6384834,0.6384834,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;277;-185.3526,627.3438;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;271;20.57252,-329.7649;Float;False;Property;_BaseColor2;Base Color 2;1;0;Create;True;0;0;False;0;1,0.9310344,0,0;0.7924528,0.2992,0.2953008,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;208;2568.44,1288.985;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-547.7504,-90.41002;Float;False;0;228;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;330;-1940.113,-90.63483;Float;False;Property;_scale;scale;18;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;439.7888,148.8591;Float;False;Property;_FlakeColorVariationAmount;Flake Color Variation Amount;6;0;Create;True;0;0;False;0;0;0.088;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;288;-913.3121,564.4912;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;217;1219.931,-40.31573;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;204;430.6655,633.4697;Float;False;Property;_FlakesSmoothness;Flakes Smoothness;10;0;Create;True;0;0;False;0;0;0.403;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;201;-1509.492,-219.6261;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;23.15472,-507.9827;Float;False;Property;_BaseColor1;Base Color 1;0;0;Create;True;0;0;False;0;1,0.9310344,0,0;1,0,0.2160807,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;298;-32.6076,1316.134;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;216;-523.6835,317.6824;Float;False;Property;_FlakesColor1;Flakes Color 1;7;0;Create;True;0;0;False;0;1,0.9310344,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;795.6452,351.8852;Float;False;Property;_FlakesMetallic;Flakes Metallic;9;0;Create;True;0;0;False;0;0;0.549;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;880.5789,28.53017;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-561.7686,221.575;Float;False;Property;_FlakesBump;Flakes Bump;12;0;Create;True;0;0;False;0;0;0.074;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;284;291.885,-1.620189;Float;False;FlakeMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;798.0975,265.6939;Float;False;Property;_BaseMetallic;Base Metallic;2;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;228;-91.33389,-112.8089;Float;True;Property;_FlakesRGBcolorvariationAmask;Flakes (RGB = color variation, A = mask);5;0;Create;True;0;0;False;0;2741be98b31d56c43ad9cfbcaf99a799;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;233;431.4409,553.8036;Float;False;Property;_BaseSmoothness;Base Smoothness;3;0;Create;True;0;0;False;0;0;0.886;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;218;1208.977,277.6431;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;218.9914,1324.712;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-131.0492,180.0499;Float;True;Property;_FlakesNormal;Flakes Normal;11;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;291;427.4925,136.2562;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;1730.49,170.9699;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;278;762.8654,-251.6517;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;839.382,441.7393;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;328;2756.206,1064.791;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;YQ/car;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;292;-1540.492,-275.3257;Float;False;348.1;312.8;Comment;0;Dual Toning Factor;1,1,1,1;0;0
WireConnection;306;0;301;1
WireConnection;306;1;307;0
WireConnection;306;2;238;0
WireConnection;237;0;279;0
WireConnection;237;1;47;0
WireConnection;171;5;180;0
WireConnection;308;0;237;0
WireConnection;308;1;306;0
WireConnection;335;0;333;0
WireConnection;335;1;334;0
WireConnection;166;1;171;0
WireConnection;166;3;211;0
WireConnection;166;4;172;0
WireConnection;319;0;308;0
WireConnection;332;0;335;0
WireConnection;296;0;279;0
WireConnection;227;0;291;0
WireConnection;227;1;228;0
WireConnection;227;2;290;0
WireConnection;232;0;233;0
WireConnection;232;1;204;0
WireConnection;232;2;285;0
WireConnection;277;0;216;0
WireConnection;277;1;263;0
WireConnection;277;2;288;0
WireConnection;208;0;332;0
WireConnection;208;1;166;0
WireConnection;208;2;319;0
WireConnection;288;0;201;0
WireConnection;217;0;278;0
WireConnection;217;1;227;0
WireConnection;217;2;287;0
WireConnection;201;1;329;0
WireConnection;201;2;330;0
WireConnection;201;3;331;0
WireConnection;298;0;296;0
WireConnection;284;0;228;4
WireConnection;228;1;9;0
WireConnection;218;0;219;0
WireConnection;218;1;5;0
WireConnection;218;2;286;0
WireConnection;299;0;298;0
WireConnection;299;1;306;0
WireConnection;7;1;9;0
WireConnection;7;5;11;0
WireConnection;291;0;277;0
WireConnection;1;0;217;0
WireConnection;1;1;7;0
WireConnection;1;3;218;0
WireConnection;1;4;232;0
WireConnection;1;5;299;0
WireConnection;278;0;4;0
WireConnection;278;1;271;0
WireConnection;278;2;201;0
WireConnection;328;13;208;0
ASEEND*/
//CHKSM=AC519EA2FD242546A942FE068F8DA1D7F89A0C58