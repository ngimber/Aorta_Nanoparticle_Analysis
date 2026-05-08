# Aortic Nanoparticle Analysis

A reproducible image analysis pipeline for detecting and quantifying nanoparticles in aortic tissue. 
Detailed methodological information is provided in the methods section of ...manuscript in preparation...
---

## Overview

This repository provides a workflow for automated single-particle detection and counting in fluorescence microscopy images of aortic slices using ImageJ.

---

## Analysis Pipeline

### 1. Noise Reduction
Fourier frequency filtering removes large-scale structures (>110 nm) and reduces shot noise.

### 2. Image Smoothing
Gaussian blur (σ = 220 nm) is applied to stabilize detection.

### 3. Feature Enhancement
Mexican Hat filtering enhances particle-like structures.

### 4. Particle Detection
Local maxima are identified using ImageJ’s “Find Local Maxima” (noise tolerance = 2).

### 5. Artifact Removal
Particles are filtered based on:
- Circularity > 0.6  
- Area < 0.3 µm²  
- Spatial constraint within 1.65 µm radius  

---

## Requirements

- ImageJ or Fiji
- Fluorescence microscopy images

---

## Citation

Schindelin, J. et al. (2012). Fiji: an open-source platform for biological-image analysis. Nature Methods, 9(7), 676–682.  
DOI: 10.1038/nmeth.2019
