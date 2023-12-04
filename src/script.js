import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import waterVertexShader from './shaders/waterRipple/vertex.glsl'
import waterFragmentBufferShader from './shaders/waterRipple/buffer_a_fragment.glsl'
import waterFragmentShader from './shaders/waterRipple/final_fragment.glsl'

class BufferShader {
  constructor(fragmentShader, uniforms = {}, width = 1, height = 1) {
    this.uniforms = uniforms
    this.material = new THREE.ShaderMaterial({
      fragmentShader: fragmentShader,
      vertexShader: waterVertexShader,
      uniforms: uniforms,
    })
    this.scene = new THREE.Scene()
    this.scene.add(
      new THREE.Mesh(
        new THREE.PlaneGeometry(width, height, 1, 1),
        this.material
      )
    )
  }
}

class BufferManager {
  constructor(renderer, size) {
    this.renderer = renderer

    this.readBuffer = new THREE.WebGLRenderTarget(size.width, size.height, {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.UVMapping,
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
      stencilBuffer: true,
    })

    this.writeBuffer = this.readBuffer.clone()
  }

  swap() {
    const temp = this.readBuffer
    this.readBuffer = this.writeBuffer
    this.writeBuffer = temp
  }

  render(scene, camera, toScreen = false) {
    if (toScreen) {
      this.renderer.render(scene, camera)
    } else {
      this.renderer.setRenderTarget(this.writeBuffer)
      this.renderer.clear()
      this.renderer.render(scene, camera)
      this.renderer.setRenderTarget(null)
    }
    this.swap()
  }
}

// Canvas
const canvas = document.querySelector('canvas.webgl')

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
const channel1 = textureLoader.load('/textures/test.jpg')

/**
 * Event Listener
 */
let counter = 0
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight,
}
const mousePosition = new THREE.Vector4()
window.addEventListener('resize', () => {
  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update render target sizes
  targetA.setSize(window.innerWidth, window.innerHeight)
  targetB.setSize(window.innerWidth, window.innerHeight)

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

window.addEventListener('mousedown', () => {
  mousePosition.setZ(1)
  counter = 0
})

window.addEventListener('mouseup', () => {
  mousePosition.setZ(0)
})

window.addEventListener('mousemove', (event) => {
  mousePosition.setX(event.clientX)
  mousePosition.setY(sizes.height - event.clientY)
})

/**
 * Camera
 */
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1)

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

const targetA = new BufferManager(renderer, {
  width: sizes.width,
  height: sizes.height,
})

const targetB = new BufferManager(renderer, {
  width: sizes.width,
  height: sizes.height,
})

const uResolution = new THREE.Vector3(
  sizes.width,
  sizes.height,
  window.devicePixelRatio
)

// Material
const materialBufferA = new BufferShader(
  waterFragmentBufferShader,
  {
    uResolution: {
      value: uResolution,
    },
    uMousePosition: { value: mousePosition },
    uChannel0: { value: null },
    uFrame: { value: 0 },
  },
  sizes.width,
  sizes.height
)

const materialImage = new BufferShader(waterFragmentShader, {
  uResolution: {
    value: uResolution,
  },
  uChannel0: { value: null },
  uChannel1: { value: channel1 },
})

/**
 * Animate
 */
const tick = () => {
  // Update material
  materialBufferA.uniforms['uFrame'].value = counter++

  materialBufferA.uniforms['uChannel0'].value = targetA.readBuffer.texture
  targetA.render(materialBufferA.scene, camera)

  materialImage.uniforms['uChannel0'].value = targetA.readBuffer.texture
  targetB.render(materialImage.scene, camera, true)
  console.log(mousePosition)
  console.log(window.innerHeight)

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
