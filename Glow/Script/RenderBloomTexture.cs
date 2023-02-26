using UnityEngine;
using System.Collections;
using  Cinemachine;
using Unity.VisualScripting;
using ThirdPerson;
/// <summary>
/// 渲染需要广泛那部分的图
/// </summary>
public class RenderBloomTexture : MonoBehaviour
{
    public ThirdPersonShooterController thirdPersonShooterController;
    //渲染需要的泛光摄像机，需要跟随着启用的虚拟相机
    public CinemachineVirtualCamera aimVirtualCamera;
    /// <summary>
    /// 主摄像机
    /// </summary>
    public Camera m_FollowCamera;

    /// <summary>
    /// 渲染需要泛光的摄像机
    /// </summary>
    private Camera m_Camera;

    /// <summary>
    /// 替换shader
    /// </summary>
    public Shader replaceShader;


    void Start()
    {
        m_Camera = GetComponent<Camera>();
        //摄像机背景要设置为黑色
        m_Camera.enabled = false;
        m_Camera.clearFlags = CameraClearFlags.SolidColor;
        m_Camera.backgroundColor = Color.black;
        UpdateCamera();
        UpdateCameraSetting();
    }

    void LateUpdate()
    {
        UpdateCamera();
        //调用渲染
        m_Camera.RenderWithShader(replaceShader, "RenderType");
    }

    void UpdateCamera()
    {
        transform.position = m_FollowCamera.transform.position;
        transform.rotation = m_FollowCamera.transform.rotation;
        
    }

    [System.Obsolete]
    void UpdateCameraSetting()
    {
        if (aimVirtualCamera.gameObject.activeSelf)
        {
            Debug.Log("Yes");
            m_Camera.orthographic = aimVirtualCamera.m_Lens.Orthographic;
            m_Camera.orthographicSize = aimVirtualCamera.m_Lens.OrthographicSize;
            m_Camera.nearClipPlane = aimVirtualCamera.m_Lens.NearClipPlane;
            m_Camera.farClipPlane = aimVirtualCamera.m_Lens.FarClipPlane;
            m_Camera.fieldOfView = aimVirtualCamera.m_Lens.FieldOfView;
           
         
        }
        else
        {
            m_Camera.orthographic = m_FollowCamera.orthographic;
            m_Camera.orthographicSize = m_FollowCamera.orthographicSize;
            m_Camera.nearClipPlane = m_FollowCamera.nearClipPlane;
            m_Camera.farClipPlane = m_FollowCamera.farClipPlane;
            m_Camera.fieldOfView = m_FollowCamera.fieldOfView;
        }
    }
}